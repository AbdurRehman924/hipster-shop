gitops/
├── applications/           # ArgoCD Application definitions
│   ├── hipster-shop.yaml
│   ├── monitoring.yaml
│   ├── logging.yaml
│   └── istio.yaml
├── environments/          # Environment-specific configs
│   ├── dev/
│   │   ├── hipster-shop/
│   │   └── kustomization.yaml
│   ├── staging/
│   │   ├── hipster-shop/
│   │   └── kustomization.yaml
│   └── prod/
│       ├── hipster-shop/
│       └── kustomization.yaml
└── base/                  # Base configurations
    ├── hipster-shop/
    │   ├── frontend.yaml
    │   ├── cartservice.yaml
    │   └── kustomization.yaml
    └── monitoring/
        └── prometheus.yaml
