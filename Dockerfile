# Giai đoạn 1: Build file chạy (Binary)
FROM golang:1.24-alpine AS builder

# Cài đặt các công cụ cần thiết
RUN apk add --no-cache nodejs npm bash git gzip brotli zstd

WORKDIR /app

# Copy toàn bộ mã nguồn vào
COPY . .

# Cài đặt dependencies và build assets
RUN npm ci
RUN go mod download
RUN go generate ./...
RUN ./web/build.sh
RUN ./xess/build.sh
RUN ./lib/challenge/preact/build.sh

# Build code Go thành file chạy
RUN CGO_ENABLED=0 GOOS=linux go build -o anubis_binary ./cmd/anubis

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