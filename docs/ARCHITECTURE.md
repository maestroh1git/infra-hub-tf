# maestrohwithit Infrastructure Architecture

Visual diagrams of the infrastructure architecture across all environments.

## Table of Contents

- [High-Level Overview](#high-level-overview)
- [Network Architecture](#network-architecture)
- [Application Architecture](#application-architecture)
- [Data Flow](#data-flow)
- [Disaster Recovery](#disaster-recovery)
- [CI/CD Pipeline](#cicd-pipeline)

---

## High-Level Overview

### Multi-Environment Architecture

```mermaid
graph TB
    subgraph "Development Environment"
        DEV[Dev VPC<br/>10.0.0.0/16]
        DEV_EC2[EC2 t3.micro]
        DEV_RDS[RDS t3.micro]
        DEV --> DEV_EC2
        DEV --> DEV_RDS
    end
    
    subgraph "Staging Environment"
        STG[Staging VPC<br/>10.1.0.0/16]
        STG_EKS[EKS Cluster<br/>2 Nodes]
        STG_RDS[RDS t3.small]
        STG --> STG_EKS
        STG --> STG_RDS
    end
    
    subgraph "Production Environment"
        PROD[Production VPC<br/>10.2.0.0/16]
        PROD_EKS[EKS Cluster<br/>Multi-AZ]
        PROD_RDS[RDS Multi-AZ<br/>t3.medium]
        PROD_ALB[Application LB]
        PROD --> PROD_ALB
        PROD_ALB --> PROD_EKS
        PROD --> PROD_RDS
    end
    
    USERS[Users] --> PROD_ALB
    DEVS[Developers] --> DEV
    QA[QA Team] --> STG
    
    style DEV fill:#e1f5ff
    style STG fill:#fff4e1
    style PROD fill:#ffe1e1
```

---

## Network Architecture

### Production VPC Architecture

```mermaid
graph TB
    subgraph "VPC 10.2.0.0/16"
        subgraph "Availability Zone A"
            PUB_A[Public Subnet<br/>10.2.1.0/24]
            PRIV_A[Private Subnet<br/>10.2.4.0/24]
            NAT_A[NAT Gateway]
            PUB_A --> NAT_A
        end
        
        subgraph "Availability Zone B"
            PUB_B[Public Subnet<br/>10.2.2.0/24]
            PRIV_B[Private Subnet<br/>10.2.5.0/24]
            NAT_B[NAT Gateway]
            PUB_B --> NAT_B
        end
        
        subgraph "Availability Zone C"
            PUB_C[Public Subnet<br/>10.2.3.0/24]
            PRIV_C[Private Subnet<br/>10.2.6.0/24]
            NAT_C[NAT Gateway]
            PUB_C --> NAT_C
        end
        
        IGW[Internet Gateway]
        
        PUB_A --> IGW
        PUB_B --> IGW
        PUB_C --> IGW
        
        ALB[Application<br/>Load Balancer]
        EKS_A[EKS Node]
        EKS_B[EKS Node]
        EKS_C[EKS Node]
        RDS_PRIMARY[RDS Primary]
        RDS_STANDBY[RDS Standby]
        
        ALB --> PUB_A
        ALB --> PUB_B
        ALB --> PUB_C
        
        EKS_A --> PRIV_A
        EKS_B --> PRIV_B
        EKS_C --> PRIV_C
        
        RDS_PRIMARY --> PRIV_A
        RDS_STANDBY --> PRIV_B
        
        NAT_A --> PRIV_A
        NAT_B --> PRIV_B
        NAT_C --> PRIV_C
    end
    
    INTERNET[Internet] --> IGW
    
    style PRIV_A fill:#f0f0f0
    style PRIV_B fill:#f0f0f0
    style PRIV_C fill:#f0f0f0
    style PUB_A fill:#e3f2fd
    style PUB_B fill:#e3f2fd
    style PUB_C fill:#e3f2fd
```

---

## Application Architecture

### Production Application Stack

```mermaid
graph TB
    subgraph "Client Layer"
        WEB[Web Browser]
        MOBILE[Mobile App]
    end
    
    subgraph "CDN & DNS"
        R53[Route 53<br/>DNS]
        CF[CloudFront<br/>CDN]
    end
    
    subgraph "Load Balancing"
        ALB[Application<br/>Load Balancer]
        TLS[TLS/SSL<br/>Certificate]
    end
    
    subgraph "Application Layer - EKS"
        subgraph "Pods"
            API1[API Pod 1]
            API2[API Pod 2]
            API3[API Pod 3]
        end
        HPA[Horizontal Pod<br/>Autoscaler]
    end
    
    subgraph "Data Layer"
        RDS_M[RDS Primary<br/>PostgreSQL]
        RDS_S[RDS Standby<br/>Multi-AZ]
        REDIS[ElastiCache<br/>Redis]
    end
    
    subgraph "Storage"
        S3_ASSETS[S3 Assets<br/>Images]
        S3_LOGS[S3 Logs<br/>Application]
        S3_BACKUP[S3 Backups]
    end
    
    subgraph "Monitoring"
        CW[CloudWatch<br/>Metrics]
        FLOW[VPC Flow<br/>Logs]
        XRAY[X-Ray<br/>Tracing]
    end
    
    WEB --> R53
    MOBILE --> R53
    R53 --> CF
    CF --> ALB
    ALB --> TLS
    TLS --> API1
    TLS --> API2
    TLS --> API3
    
    HPA -.->|scales| API1
    HPA -.->|scales| API2
    HPA -.->|scales| API3
    
    API1 --> RDS_M
    API2 --> RDS_M
    API3 --> RDS_M
    
    API1 --> REDIS
    API2 --> REDIS
    API3 --> REDIS
    
    RDS_M -.->|replication| RDS_S
    
    API1 --> S3_ASSETS
    API2 --> S3_ASSETS
    API3 --> S3_ASSETS
    
    API1 -.->|logs| S3_LOGS
    API1 -.->|metrics| CW
    ALB -.->|logs| FLOW
    API1 -.->|traces| XRAY
    
    style API1 fill:#4caf50
    style API2 fill:#4caf50
    style API3 fill:#4caf50
    style RDS_M fill:#2196f3
    style RDS_S fill:#64b5f6
```

---

## Data Flow

### Request Flow

```mermaid
sequenceDiagram
    participant User
    participant Route53
    participant ALB
    participant API
    participant Cache
    participant RDS
    participant S3
    
    User->>Route53: api.maestrohwithit.com
    Route53->>ALB: Resolve to LB
    ALB->>API: HTTPS Request
    
    API->>Cache: Check Redis
    
    alt Cache Hit
        Cache-->>API: Return cached data
        API-->>User: Response (fast)
    else Cache Miss
        API->>RDS: Query database
        RDS-->>API: Return data
        API->>Cache: Store in cache
        API->>S3: Store asset
        API-->>User: Response
    end
    
    API->>CloudWatch: Send metrics
    API->>S3: Write logs
```

### Deployment Flow

```mermaid
graph LR
    DEV[Developer] -->|git push| GH[GitHub]
    GH -->|trigger| ACT[GitHub Actions]
    
    ACT -->|1. Lint| LINT[Terraform fmt]
    ACT -->|2. Scan| SEC[tfsec + Checkov]
    ACT -->|3. Validate| VAL[Terraform validate]
    ACT -->|4. Plan| PLAN[Terraform plan]
    
    PLAN -->|5. Review| APPROVAL{Manual<br/>Approval}
    
    APPROVAL -->|Approved| APPLY[Terraform apply]
    APPROVAL -->|Rejected| STOP[Stop]
    
    APPLY -->|Deploy| AWS[AWS Resources]
    AWS -->|Verify| MONITOR[CloudWatch]
    MONITOR -->|Alert| SNS[SNS Notifications]
    
    style SEC fill:#ff6b6b
    style APPROVAL fill:#ffd93d
    style AWS fill:#4ecdc4
```

---

## Disaster Recovery

### Backup & Recovery Architecture

```mermaid
graph TB
    subgraph "Production Resources"
        RDS[RDS Database]
        EC2[EC2 Instances]
        EBS[EBS Volumes]
    end
    
    subgraph "AWS Backup"
        VAULT[Backup Vault<br/>KMS Encrypted]
        PLAN[Backup Plan<br/>Daily 5AM]
    end
    
    subgraph "Storage"
        S3_BACKUP[S3 Backup<br/>Bucket]
        SNAPSHOT[RDS Snapshots<br/>Automated]
        AMI[EC2 AMIs<br/>Weekly]
    end
    
    subgraph "Recovery"
        RESTORE[Restore<br/>Procedure]
        NEW_RDS[New RDS]
        NEW_EC2[New EC2]
    end
    
    RDS -->|tagged Backup=true| PLAN
    EC2 -->|tagged Backup=true| PLAN
    EBS -->|tagged Backup=true| PLAN
    
    PLAN --> VAULT
    VAULT --> S3_BACKUP
    
    RDS -.->|auto| SNAPSHOT
    EC2 -.->|weekly| AMI
    
    SNAPSHOT -.->|restore| RESTORE
    AMI -.->|restore| RESTORE
    S3_BACKUP -.->|restore| RESTORE
    
    RESTORE --> NEW_RDS
    RESTORE --> NEW_EC2
    
    style VAULT fill:#4caf50
    style RESTORE fill:#ff9800
```

### Recovery Time Objectives

```mermaid
gantt
    title Disaster Recovery Timeline
    dateFormat  HH:mm
    axisFormat %H:%M
    
    section Detection
    Incident Detected           :a1, 00:00, 5m
    
    section Assessment
    Impact Assessment           :a2, after a1, 10m
    Decision to Restore         :a3, after a2, 5m
    
    section Recovery (RDS)
    Identify Snapshot           :b1, after a3, 5m
    Initiate Restore            :b2, after b1, 2m
    RDS Restore Process         :b3, after b2, 30m
    Update Endpoints            :b4, after b3, 5m
    Verification                :b5, after b4, 8m
    
    section Total
    RTO Target (1 hour)         :milestone, after b5, 0m
```

---

## CI/CD Pipeline

### Deployment Pipeline

```mermaid
graph TB
    START[Git Push] --> TRIGGER{Branch?}
    
    TRIGGER -->|main + dev paths| DEV_PIPE[Dev Pipeline]
    TRIGGER -->|main + staging paths| STG_PIPE[Staging Pipeline]
    TRIGGER -->|manual trigger| PROD_PIPE[Prod Pipeline]
    
    subgraph "Dev Deployment (Auto)"
        DEV_PIPE --> DEV_LINT[Terraform fmt]
        DEV_LINT --> DEV_SEC[Security Scan]
        DEV_SEC --> DEV_PLAN[Terraform Plan]
        DEV_PLAN --> DEV_APPLY[Terraform Apply]
    end
    
    subgraph "Staging Deployment"
        STG_PIPE --> STG_LINT[Terraform fmt]
        STG_LINT --> STG_SEC[Security Scan]
        STG_SEC --> STG_PLAN[Terraform Plan]
        STG_PLAN --> STG_APPLY[Terraform Apply]
    end
    
    subgraph "Production Deployment (Protected)"
        PROD_PIPE --> PROD_LINT[Terraform fmt]
        PROD_LINT --> PROD_SEC[Security Scan]
        PROD_SEC --> PROD_PLAN[Terraform Plan]
        PROD_PLAN --> APPROVAL{Manual<br/>Approval}
        APPROVAL -->|Approved| PROD_APPLY[Terraform Apply]
        APPROVAL -->|Rejected| CANCEL[Cancel]
    end
    
    DEV_APPLY --> NOTIFY_DEV[Notify Slack]
    STG_APPLY --> NOTIFY_STG[Notify Slack]
    PROD_APPLY --> NOTIFY_PROD[Notify Slack]
    
    style DEV_APPLY fill:#4caf50
    style STG_APPLY fill:#ff9800
    style PROD_APPLY fill:#f44336
    style APPROVAL fill:#ffd93d
```

---

## Security Architecture

### Security Layers

```mermaid
graph TB
    subgraph "Network Security"
        VPC[VPC Isolation]
        SG[Security Groups]
        NACL[Network ACLs]
        FLOW[VPC Flow Logs]
    end
    
    subgraph "Application Security"
        WAF[AWS WAF]
        SHIELD[AWS Shield]
        ACM[SSL/TLS Certs]
        SECRETS[Secrets Manager]
    end
    
    subgraph "Data Security"
        KMS[KMS Encryption]
        S3_ENC[S3 Encryption]
        RDS_ENC[RDS Encryption]
        EBS_ENC[EBS Encryption]
    end
    
    subgraph "Access Control"
        IAM[IAM Roles]
        MFA[MFA Required]
        ASSUME[AssumeRole]
        POLICY[Least Privilege]
    end
    
    subgraph "Monitoring & Compliance"
        CT[CloudTrail]
        CONFIG[AWS Config]
        GD[GuardDuty]
        SCAN[tfsec/Checkov]
    end
    
    INTERNET[Internet] --> WAF
    WAF --> SHIELD
    SHIELD --> ACM
    ACM --> VPC
    
    VPC --> SG
    SG --> NACL
    NACL -.->|logs| FLOW
    
    IAM --> ASSUME
    ASSUME --> POLICY
    POLICY -.->|audit| CT
    
    KMS --> S3_ENC
    KMS --> RDS_ENC
    KMS --> EBS_ENC
    KMS --> SECRETS
    
    CT -.->|events| CONFIG
    CONFIG -.->|rules| GD
    
    style KMS fill:#4caf50
    style IAM fill:#2196f3
    style SCAN fill:#ff9800
```

---

## Cost Optimization

### Cost by Environment

```mermaid
pie title Monthly Infrastructure Costs
    "Production" : 490
    "Staging" : 150
    "Dev" : 50
```

### Cost Breakdown (Production)

```mermaid
pie title Production Cost Breakdown
    "Compute (EC2/EKS)" : 245
    "Database (RDS)" : 157
    "Storage (S3)" : 42
    "Networking" : 31
    "Monitoring" : 15
```

---

## Scaling Architecture

### Auto Scaling Flow

```mermaid
graph TB
    METRICS[CloudWatch<br/>Metrics] -->|CPU > 70%| ALARM[CloudWatch<br/>Alarm]
    
    ALARM --> HPA{Horizontal Pod<br/>Autoscaler}
    
    HPA -->|Scale Up| ADD[Add Pods<br/>3 → 5]
    HPA -->|Scale Down| REMOVE[Remove Pods<br/>5 → 3]
    
    ADD --> NODES{Enough<br/>Nodes?}
    
    NODES -->|No| CA[Cluster<br/>Autoscaler]
    NODES -->|Yes| DONE[Deploy Pods]
    
    CA --> ADD_NODE[Add EKS<br/>Nodes]
    ADD_NODE --> DONE
    
    REMOVE --> CLEANUP[Cleanup<br/>Resources]
    
    style ADD fill:#4caf50
    style REMOVE fill:#ff9800
    style CA fill:#2196f3
```

---

## Module Dependencies

### Terraform Module Graph

```mermaid
graph TD
    VPC[VPC Module] --> SG[Security Groups]
    VPC --> FLOW[VPC Flow Logs]
    
    SG --> EC2[EC2 Module]
    SG --> RDS[RDS Module]
    SG --> ALB[ALB Module]
    SG --> EKS[EKS Module]
    
    VPC --> EKS
    VPC --> RDS
    VPC --> ALB
    
    KMS[KMS Module] --> S3[S3 Storage]
    KMS --> RDS
    KMS --> BACKUP[Backup Module]
    
    IAM[IAM Module] --> EC2
    IAM --> EKS
    IAM --> BACKUP
    
    CW[CloudWatch Module] --> ALARMS[CloudWatch Alarms]
    
    EC2 -.->|tagged| BACKUP
    RDS -.->|tagged| BACKUP
    
    style VPC fill:#e3f2fd
    style KMS fill:#c8e6c9
    style IAM fill:#fff9c4
```

---

## Glossary

| Term | Description |
|------|-------------|
| **VPC** | Virtual Private Cloud - Isolated network |
| **AZ** | Availability Zone - Physical datacenter |
| **NAT** | Network Address Translation - Outbound internet |
| **IGW** | Internet Gateway - Inbound internet |
| **ALB** | Application Load Balancer - L7 load balancer |
| **EKS** | Elastic Kubernetes Service - Managed K8s |
| **RDS** | Relational Database Service - Managed DB |
| **Multi-AZ** | Multiple Availability Zones - HA setup |
| **HPA** | Horizontal Pod Autoscaler - K8s scaling |
| **RTO** | Recovery Time Objective - Max downtime |
| **RPO** | Recovery Point Objective - Max data loss |

---

**Architecture Documentation Version:** 1.0  
**Last Updated:** 2024-01-20  
**Maintained By:** DevOps Team
