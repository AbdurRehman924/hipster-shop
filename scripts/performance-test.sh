#!/bin/bash
set -e

# Performance Benchmark Script for Hipster Shop
# Tests application performance and generates reports

echo "🚀 Starting Performance Benchmark..."

# Configuration
DURATION=${1:-60}  # Test duration in seconds
USERS=${2:-10}     # Concurrent users
FRONTEND_URL="http://$(kubectl get svc frontend -n hipster-shop -o jsonpath='{.status.loadBalancer.ingress[0].ip}'):80"

# Check if frontend is accessible
echo "📡 Checking frontend accessibility..."
if ! kubectl get svc frontend -n hipster-shop &>/dev/null; then
    echo "❌ Frontend service not found. Please deploy the application first."
    exit 1
fi

# Use port-forward if LoadBalancer IP is not available
if [[ "$FRONTEND_URL" == "http://:80" ]]; then
    echo "🔄 Using port-forward for testing..."
    kubectl port-forward svc/frontend 8080:8080 -n hipster-shop &
    PORT_FORWARD_PID=$!
    FRONTEND_URL="http://localhost:8080"
    sleep 5
fi

# Create temporary test script
cat > /tmp/load_test.py << 'EOF'
import time
import requests
import random
import statistics
from concurrent.futures import ThreadPoolExecutor
import sys

class LoadTester:
    def __init__(self, base_url, duration, users):
        self.base_url = base_url
        self.duration = duration
        self.users = users
        self.results = []
        
    def user_journey(self):
        """Simulate a typical user journey"""
        session = requests.Session()
        journey_times = []
        
        start_time = time.time()
        while time.time() - start_time < self.duration:
            try:
                # Home page
                response = session.get(f"{self.base_url}/")
                journey_times.append(response.elapsed.total_seconds())
                
                # Product page
                response = session.get(f"{self.base_url}/product/OLJCESPC7Z")
                journey_times.append(response.elapsed.total_seconds())
                
                # Add to cart
                response = session.post(f"{self.base_url}/cart", data={
                    'product_id': 'OLJCESPC7Z',
                    'quantity': 1
                })
                journey_times.append(response.elapsed.total_seconds())
                
                time.sleep(random.uniform(1, 3))  # Think time
                
            except Exception as e:
                print(f"Request failed: {e}")
                
        return journey_times
    
    def run_test(self):
        print(f"🔥 Starting load test: {self.users} users for {self.duration}s")
        
        with ThreadPoolExecutor(max_workers=self.users) as executor:
            futures = [executor.submit(self.user_journey) for _ in range(self.users)]
            
            for future in futures:
                self.results.extend(future.result())
        
        self.generate_report()
    
    def generate_report(self):
        if not self.results:
            print("❌ No results to report")
            return
            
        print("\n📊 Performance Report")
        print("=" * 50)
        print(f"Total Requests: {len(self.results)}")
        print(f"Average Response Time: {statistics.mean(self.results):.3f}s")
        print(f"Median Response Time: {statistics.median(self.results):.3f}s")
        print(f"95th Percentile: {sorted(self.results)[int(len(self.results) * 0.95)]:.3f}s")
        print(f"99th Percentile: {sorted(self.results)[int(len(self.results) * 0.99)]:.3f}s")
        print(f"Min Response Time: {min(self.results):.3f}s")
        print(f"Max Response Time: {max(self.results):.3f}s")
        print(f"Requests/Second: {len(self.results) / duration:.2f}")

if __name__ == "__main__":
    base_url = sys.argv[1]
    duration = int(sys.argv[2])
    users = int(sys.argv[3])
    
    tester = LoadTester(base_url, duration, users)
    tester.run_test()
EOF

# Install dependencies if needed
if ! python3 -c "import requests" 2>/dev/null; then
    echo "📦 Installing Python dependencies..."
    pip3 install requests
fi

# Run the load test
echo "🎯 Running load test against $FRONTEND_URL"
echo "⏱️  Duration: ${DURATION}s, Users: ${USERS}"

python3 /tmp/load_test.py "$FRONTEND_URL" "$DURATION" "$USERS"

# Cleanup
if [[ -n "$PORT_FORWARD_PID" ]]; then
    kill $PORT_FORWARD_PID 2>/dev/null || true
fi

rm -f /tmp/load_test.py

# Collect metrics from Prometheus if available
echo -e "\n📈 Collecting metrics from Prometheus..."
if kubectl get svc prometheus -n monitoring &>/dev/null; then
    kubectl port-forward svc/prometheus 9090:9090 -n monitoring &
    PROM_PID=$!
    sleep 3
    
    echo "🔍 Key metrics during test period:"
    curl -s "http://localhost:9090/api/v1/query?query=rate(http_requests_total[5m])" | \
        python3 -c "import sys, json; data=json.load(sys.stdin); print(f'Request Rate: {data[\"data\"][\"result\"][0][\"value\"][1] if data[\"data\"][\"result\"] else \"N/A\"} req/s')" 2>/dev/null || echo "Request rate: N/A"
    
    kill $PROM_PID 2>/dev/null || true
fi

echo "✅ Performance benchmark completed!"
