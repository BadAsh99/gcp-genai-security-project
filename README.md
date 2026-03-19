# gcp-genai-security-project

> Side-by-side GCP GenAI deployments: insecure vs. remediated — a practical security comparison

![Terraform](https://img.shields.io/badge/Terraform-IaC-purple?logo=terraform)
![GCP](https://img.shields.io/badge/GCP-google_5.x-red?logo=googlecloud)
![Vertex AI](https://img.shields.io/badge/Vertex_AI-GenAI-blue?logo=googlecloud)
![Security](https://img.shields.io/badge/Focus-Cloud_Security-red)

---

## Overview

An educational security project that deploys the **same GenAI application twice on GCP** — once with common security misconfigurations, once with production-grade hardening. The two deployments are kept structurally identical so differences are immediately visible, making this a practical reference for anyone securing GenAI workloads on GCP.

The pattern reflects real-world scenarios where GenAI features are shipped quickly and security is bolted on later. This project shows what "bolted on later" should actually look like.

---

## Side-by-Side Comparison

| Area | Insecure (`1_`) | Remediated (`2_`) |
|------|----------------|------------------|
| **Service Account** | Default compute SA (over-privileged) | Dedicated SA with minimal IAM roles |
| **Secret Management** | API keys hardcoded or in env vars | Secret Manager with restrictive accessors |
| **Network** | No VPC controls, open firewall rules | Isolated VPC, restrictive ingress/egress |
| **Cloud Run Identity** | Default service identity | Workload Identity bound to custom SA |
| **Storage** | Public or default ACLs | Private with IAM-only access |
| **IAM** | Broad predefined roles | Granular custom role bindings |

---

## Architecture

```
INSECURE (1_insecure_deployment/)        REMEDIATED (2_remediated_deployment/)

Cloud Run                                Cloud Run
  └─ Default SA ──────────────►            └─ Custom SA (minimal roles)
       │                                          │
       ├─► Secret Manager                         ├─► Secret Manager
       │   (no IAM binding)                       │   (secretAccessor binding)
       │                                          │
       ├─► Vertex AI                              ├─► Vertex AI
       │   (public endpoint)                      │   (Workload Identity)
       │                                          │
       └─► Cloud Storage                          └─► Cloud Storage
           (default ACLs)                             (private, IAM-only)
```

---

## Structure

```
gcp-genai-security-project/
├── 1_insecure_deployment/
│   ├── main.tf        # Provider + API enablement
│   ├── compute.tf     # Compute instances (default SA)
│   ├── genai.tf       # Vertex AI + Cloud Run (insecure config)
│   ├── network.tf     # Open network rules
│   ├── storage.tf     # Storage with loose ACLs
│   └── variables.tf
│
└── 2_remediated_deployment/
    ├── main.tf        # Provider + API enablement
    ├── compute.tf     # Compute instances (dedicated SA)
    ├── genai.tf       # Vertex AI + Cloud Run (hardened)
    ├── iam.tf         # Explicit IAM bindings
    ├── network.tf     # Restricted VPC + firewall rules
    ├── storage.tf     # Private storage + IAM-only access
    └── variables.tf
```

---

## Tech Stack

| Component | Technology |
|-----------|-----------|
| IaC | Terraform, google 5.40.0 |
| Cloud | Google Cloud Platform |
| AI/ML | Vertex AI (GenAI APIs) |
| Compute | Cloud Run, Compute Engine |
| Security | IAM, Secret Manager, VPC Firewall |
| Storage | Google Cloud Storage |

---

## Getting Started

### Deploy Insecure Version (study the risks)

```bash
cd 1_insecure_deployment
terraform init
terraform apply -var="gcp_project_id=YOUR_PROJECT"
```

### Deploy Remediated Version (production pattern)

```bash
cd 2_remediated_deployment
terraform init
terraform apply -var="gcp_project_id=YOUR_PROJECT"
```

> **Note:** Deploy both in separate GCP projects or use different resource name prefixes to avoid naming conflicts.

---

## Key Lessons

1. **Default service accounts are dangerous** — they carry broad permissions inherited from the project
2. **Secret Manager ≠ secure by default** — you must explicitly bind `secretAccessor` to the right identity
3. **Workload Identity over service account keys** — eliminates long-lived credential files entirely
4. **Network default-deny** — GCP allows all internal traffic by default; explicitly deny and selectively allow
5. **Cloud Run identity matters** — the service identity determines what GCP APIs the container can call

---

## Author

**Ash Clements** — Sr. Principal Security Consultant | Cloud & AI Security
[github.com/BadAsh99](https://github.com/BadAsh99)
