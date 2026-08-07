# Terraform - AWS EKS Cluster (demo/học tập)

Dựng cluster AWS EKS với VPC riêng, node group 2-3 node `t3.medium`, có thể `apply`/`destroy` lặp lại nhiều lần để tiết kiệm chi phí AWS.

## Cấu trúc file

| File | Nội dung |
|---|---|
| `providers.tf` | Khai báo provider AWS, phiên bản Terraform, backend (tùy chọn remote state) |
| `variables.tf` | Toàn bộ biến có thể tùy chỉnh (region, kích thước node, v.v.) |
| `vpc.tf` | VPC, subnet public/private, NAT Gateway |
| `eks.tf` | Cluster EKS, node group, add-on (CoreDNS, kube-proxy, VPC CNI, EBS CSI) |
| `outputs.tf` | Giá trị trả ra sau khi apply (endpoint, lệnh cấu hình kubectl...) |
| `terraform.tfvars.example` | File mẫu để copy thành `terraform.tfvars` |

## Yêu cầu

- Terraform >= 1.5.0
- AWS CLI đã cấu hình (`aws configure`) với IAM user/role có quyền tạo VPC, EKS, IAM role
- kubectl

## Cách dùng

```bash
# 1. Copy file biến mẫu và chỉnh theo nhu cầu
cp terraform.tfvars.example terraform.tfvars

# 2. Khởi tạo Terraform (tải provider + module)
terraform init

# 3. Xem trước những gì sẽ được tạo
terraform plan

# 4. Tạo hạ tầng thật (mất khoảng 10-15 phút vì EKS control plane khởi tạo chậm)
terraform apply

# 5. Cấu hình kubectl trỏ vào cluster vừa tạo (lệnh này được in ra ở output "configure_kubectl")
aws eks update-kubeconfig --region ap-southeast-1 --name eks-observability-demo-dev

# 6. Kiểm tra cluster hoạt động
kubectl get nodes
```

## Destroy khi không dùng (quan trọng để tiết kiệm chi phí)

```bash
terraform destroy
```

Vì toàn bộ hạ tầng được định nghĩa bằng code, bạn có thể `destroy` sau mỗi buổi làm việc và `apply` lại vào buổi sau mà không mất cấu hình — tránh bị tính phí EKS control plane (~0.10 USD/giờ) và EC2 node ngoài giờ sử dụng.

## Ước tính chi phí (tham khảo, khu vực ap-southeast-1)

- EKS control plane: ~0.10 USD/giờ (~2.4 USD/ngày nếu chạy 24/24)
- 2x t3.medium on-demand: ~0.10 USD/giờ Ã 2 (~4.8 USD/ngày nếu chạy 24/24)
- NAT Gateway: ~0.045 USD/giờ + phí data transfer

=> Nên `destroy` khi không dùng, hoặc cân nhắc dùng `capacity_type = "SPOT"` trong `eks.tf` để giảm ~60-70% chi phí node.

## Ghi chú

- Mặc định cluster cho phép truy cập API endpoint từ internet (`enable_cluster_public_access = true`) để tiện học tập/demo. Trong môi trường thật nên giới hạn theo IP hoặc tắt public access.
- Muốn thêm quyền quản trị cluster cho giảng viên hướng dẫn: điền ARN IAM user của họ vào biến `additional_iam_users` trong `terraform.tfvars`.
- State file mặc định lưu local (`terraform.tfstate`). Nếu làm nhóm nhiều người hoặc nhiều máy, nên bật remote backend S3 (đã có sẵn cấu hình mẫu, comment sẵn trong `providers.tf`).
