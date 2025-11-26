# Giai đoạn 1: Build file chạy (Binary)
FROM golang:1.24-alpine AS builder

WORKDIR /app

# Copy toàn bộ mã nguồn vào
COPY . .

# Build code Go thành file chạy
# (Cần đảm bảo file html đã được embed hoặc copy theo)
RUN go mod download
RUN go build -o anubis_binary .

# Giai đoạn 2: Tạo ảnh Docker nhẹ để chạy
FROM alpine:latest

WORKDIR /root/

# Copy file chạy từ giai đoạn 1 sang
COPY --from=builder /app/anubis_binary .

# Copy thư mục templates nếu code yêu cầu file rời (Quan trọng)
# COPY --from=builder /app/templates ./templates 

# Cấp quyền chạy
RUN chmod +x anubis_binary

# Chạy app
CMD ["./anubis_binary"]