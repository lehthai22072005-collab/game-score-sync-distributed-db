# Hệ Thống Đồng Bộ Điểm Số Thời Gian Thực & Xác Định Trạng Thái Toàn Cục Nhất Quán

Dự án cuối kỳ môn **Cơ sở dữ liệu phân tán** mô phỏng một hệ thống đồng bộ điểm số trò chơi theo thời gian thực giữa nhiều Node phân tán.

Hệ thống sử dụng **Apache Kafka** để truyền sự kiện điểm số giữa các Node, đồng thời áp dụng thuật toán **Chandy-Lamport** để chụp ảnh trạng thái toàn cục nhất quán của hệ thống.

Dự án tập trung chứng minh các nội dung chính:

- Đồng bộ điểm số giữa nhiều Node theo thời gian thực.
- Duy trì tính nhất quán dữ liệu giữa các bản sao.
- Hệ thống vẫn hoạt động khi một Node bị lỗi.
- Node bị lỗi có thể khôi phục lại trạng thái sau khi chạy lại.
- Có thể lưu Snapshot trạng thái hệ thống mà không cần dừng toàn bộ hệ thống.

---

## 1. Thông tin dự án

| Mục | Nội dung |
|---|---|
| Môn học | Cơ sở dữ liệu phân tán |
| Tên nhóm | DistributedGuard |
| Thành viên | N23DCCN054 |
| Tên dự án | Hệ thống đồng bộ dữ liệu điểm số thời gian thực và xác định trạng thái toàn cục nhất quán |
| Công nghệ chính | Java Spring Boot, Apache Kafka, Docker, Zookeeper, HTML/CSS/JavaScript |
| Thuật toán sử dụng | Chandy-Lamport Snapshot Algorithm |

---

## 2. Ý tưởng chính của hệ thống

Trong hệ thống phân tán, dữ liệu thường được lưu ở nhiều máy khác nhau. Nếu một máy bị lỗi, hệ thống cần có khả năng khôi phục dữ liệu chính xác mà không làm dừng toàn bộ các máy còn lại.

Dự án này mô phỏng một hệ thống game có 3 máy chủ:

- **Node A** chạy ở cổng `8081`
- **Node B** chạy ở cổng `8082`
- **Node C** chạy ở cổng `8083`

Mỗi Node đều lưu bảng điểm người chơi trong RAM bằng `ConcurrentHashMap`.

Khi người chơi thực hiện hành động như giết quái, thắng trận hoặc thua trận, hành động đó sẽ được gửi vào Kafka. Sau đó cả 3 Node cùng nhận sự kiện từ Kafka và cập nhật điểm giống nhau.

Nhờ vậy, bảng điểm trên cả 3 Node luôn được đồng bộ.

---

## 3. Kiến trúc tổng quan

```text
[ Dashboard Web ]
       |
       | HTTP REST API
       v
+---------------+     +---------------+     +---------------+
| Node A: 8081  |     | Node B: 8082  |     | Node C: 8083  |
| Master Node   |     | Worker Node   |     | Worker Node   |
+---------------+     +---------------+     +---------------+
        ^                     ^                     ^
        |                     |                     |
        |                     |                     |
        v                     v                     v
========================================================
        Apache Kafka Bus
        Topic: player-actions-v11
========================================================
                        |
                        v
                   Zookeeper
```

### Giải thích kiến trúc

- **Dashboard Web**: Giao diện dùng để gửi hành động điểm số và quan sát trạng thái của 3 Node.
- **Node A**: Node chính, ngoài xử lý điểm số còn có nhiệm vụ phát thông điệp `MARKER` định kỳ.
- **Node B và Node C**: Các Node bản sao, cùng nhận dữ liệu từ Kafka và cập nhật điểm.
- **Apache Kafka**: Đóng vai trò là trục truyền thông điệp giữa các Node.
- **Zookeeper**: Hỗ trợ Kafka quản lý metadata và điều phối Broker.
- **Snapshot file**: Mỗi Node tự sinh file `snapshot_808x.txt` để lưu trạng thái phục hồi.

---

## 4. Bố trí thư mục dự án

Toàn bộ dự án được thiết kế theo kiểu đóng gói tự động. Các file mã nguồn, cấu hình hạ tầng và công cụ điều khiển đều nằm trong thư mục gốc.

```text
game-score-sync/
├── src/main/java/...                      Source code Java Spring Boot
├── docker-compose.yml                     Cấu hình Kafka và Zookeeper
├── demo-he-phan-tan.html                  Giao diện Web Dashboard
├── pom.xml                                Cấu hình thư viện Maven
│
├── [QUẢN LÝ HẠ TẦNG KAFKA]
│   ├── start-kafka.bat                    Bật Kafka và Zookeeper bằng Docker
│   ├── stop-kafka.bat                     Tắt Kafka và Zookeeper an toàn
│   └── reset-system.bat                   Xóa dữ liệu cũ và reset Kafka
│
├── [ĐIỀU KHIỂN HỆ THỐNG TỔNG]
│   ├── run-3-nodes.bat                    Bật tự động 3 Node Java cùng lúc
│   └── stop-3-nodes.bat                   Tắt toàn bộ 3 Node
│
├── [ĐIỀU KHIỂN ĐƠN LẺ - DÙNG CHO DEMO CHỊU LỖI]
│   ├── run-node-a.bat                     Bật riêng Node A - Port 8081
│   ├── stop-node-a.bat                    Tắt riêng Node A - Port 8081
│   ├── run-node-b.bat                     Bật riêng Node B - Port 8082
│   ├── stop-node-b.bat                    Tắt riêng Node B - Port 8082
│   ├── run-node-c.bat                     Bật riêng Node C - Port 8083
│   └── stop-node-c.bat                    Tắt riêng Node C - Port 8083
│
└── snapshot_808x.txt                      File Snapshot tự sinh khi hệ thống chạy
```

---

## 5. Yêu cầu cài đặt

Trước khi chạy dự án, máy cần cài sẵn các công cụ sau:

| Công cụ | Mục đích |
|---|---|
| Java JDK 17 | Chạy Spring Boot |
| Maven | Build và chạy project Java |
| Docker Desktop | Chạy Kafka và Zookeeper |
| Chrome hoặc Edge | Mở giao diện Dashboard |

Kiểm tra Java:

```bash
java -version
```

Kiểm tra Maven:

```bash
mvn -version
```

Kiểm tra Docker:

```bash
docker --version
```

---

## 6. Hướng dẫn chạy dự án nhanh

Để chạy hệ thống từ đầu, thực hiện lần lượt 3 bước sau.

---

### Bước 1: Bật Kafka và Zookeeper

Click đúp vào file:

```text
start-kafka.bat
```

File này sẽ khởi động Kafka và Zookeeper thông qua Docker.

Sau khi chạy, chờ khoảng 20 giây để Kafka và Zookeeper khởi động ổn định.

---

### Bước 2: Bật 3 Node Spring Boot

Click đúp vào file:

```text
run-3-nodes.bat
```

File này sẽ tự động mở 3 cửa sổ terminal, tương ứng với:

```text
Node A: http://localhost:8081
Node B: http://localhost:8082
Node C: http://localhost:8083
```

Đợi khoảng 15 - 20 giây để Spring Boot khởi động xong.

---

### Bước 3: Mở Dashboard

Click đúp vào file:

```text
demo-he-phan-tan.html
```

Dashboard sẽ mở trên trình duyệt.

Nếu cả 3 Node đều hiện trạng thái:

```text
Hệ thống Online
```

thì hệ thống đã chạy thành công.

---

## 7. Giải thích các file BAT

### Nhóm quản lý Kafka

| File | Công dụng |
|---|---|
| `start-kafka.bat` | Bật Kafka và Zookeeper bằng Docker |
| `stop-kafka.bat` | Tắt Kafka và Zookeeper |
| `reset-system.bat` | Xóa Snapshot cũ, reset dữ liệu Kafka và đưa hệ thống về trạng thái ban đầu |

### Nhóm điều khiển toàn bộ hệ thống

| File | Công dụng |
|---|---|
| `run-3-nodes.bat` | Chạy cùng lúc 3 Node Spring Boot |
| `stop-3-nodes.bat` | Tắt toàn bộ 3 Node đang chạy |

### Nhóm điều khiển từng Node

| File | Công dụng |
|---|---|
| `run-node-a.bat` | Chạy riêng Node A ở cổng 8081 |
| `stop-node-a.bat` | Tắt riêng Node A ở cổng 8081 |
| `run-node-b.bat` | Chạy riêng Node B ở cổng 8082 |
| `stop-node-b.bat` | Tắt riêng Node B ở cổng 8082 |
| `run-node-c.bat` | Chạy riêng Node C ở cổng 8083 |
| `stop-node-c.bat` | Tắt riêng Node C ở cổng 8083 |

> Ghi chú:  
> Các file `stop-node-a.bat`, `stop-node-b.bat`, `stop-node-c.bat` và `stop-3-nodes.bat` có thể dùng PowerShell để tắt tiến trình Java theo cổng mạng.  
> Nếu click đúp không tắt được tiến trình, hãy chuột phải vào file `.bat` và chọn **Run as Administrator**.

---

## 8. Các hành động điểm số được hỗ trợ

Hệ thống hỗ trợ 3 loại hành động chính:

| Hành động | Ý nghĩa | Tác động điểm |
|---|---|---|
| `KILL_MONSTER` | Người chơi giết quái | Cộng điểm |
| `WIN_MATCH` | Người chơi thắng trận | Cộng điểm |
| `LOSE_MATCH` | Người chơi thua trận | Trừ điểm |

Ví dụ dữ liệu gửi vào hệ thống:

```json
{
  "playerID": "ThaiLe",
  "actionType": "KILL_MONSTER",
  "points": 100
}
```

Nếu người chơi `ThaiLe` đang có 0 điểm, sau hành động trên điểm sẽ tăng thành 100.

---

## 9. Luồng xử lý điểm số

Quy trình xử lý một hành động điểm số diễn ra như sau:

```text
Người dùng gửi hành động trên Dashboard
        |
        v
Node nhận request POST /api/scores
        |
        v
Node gửi sự kiện vào Kafka Topic
        |
        v
Cả 3 Node cùng nhận sự kiện từ Kafka
        |
        v
Mỗi Node cập nhật scoreBoard trong RAM
        |
        v
Dashboard hiển thị điểm số mới
```

Điểm quan trọng là Node nhận request không tự cập nhật riêng lẻ. Thay vào đó, hành động được đưa vào Kafka để tất cả Node cùng xử lý theo một thứ tự chung.

Nhờ vậy, 3 Node có thể duy trì trạng thái giống nhau.

---

## 10. Cơ chế Snapshot Chandy-Lamport

Trong hệ thống này, Node A sẽ tự động gửi thông điệp đặc biệt gọi là:

```text
MARKER
```

Thông điệp `MARKER` được gửi định kỳ mỗi 10 giây.

Khi mỗi Node nhận được `MARKER`, Node đó sẽ ghi lại trạng thái hiện tại xuống file Snapshot.

Các file Snapshot có dạng:

```text
snapshot_8081.txt
snapshot_8082.txt
snapshot_8083.txt
```

Ví dụ nội dung file:

```text
15|{ThaiLe=300}
```

Ý nghĩa:

| Thành phần | Ý nghĩa |
|---|---|
| `15` | Kafka Offset cuối cùng đã xử lý |
| `{ThaiLe=300}` | Bảng điểm hiện tại trong RAM |

Nhờ Kafka đảm bảo thứ tự FIFO, `MARKER` đóng vai trò như một ranh giới logic. Các sự kiện trước `MARKER` được tính vào Snapshot, còn các sự kiện sau `MARKER` sẽ được xử lý tiếp ở giai đoạn sau.

---

## 11. Kịch bản demo kiểm thử hệ thống

Phần này dùng để trình bày khi quay video demo hoặc báo cáo đồ án.

---

### Kịch bản 1: Kiểm tra đồng bộ điểm số

Mục tiêu: Chứng minh cả 3 Node luôn có điểm số giống nhau.

Các bước thực hiện:

1. Mở Dashboard.
2. Tại khung của Node A, nhập mã người chơi.
3. Chọn hành động:

```text
KILL_MONSTER
```

4. Nhập điểm:

```text
100
```

5. Bấm gửi dữ liệu.

Kết quả mong đợi:

- Node A nhận điểm.
- Node B cũng nhận điểm.
- Node C cũng nhận điểm.
- Cả 3 Node đều hiển thị điểm `100`.

Giải thích:

Node A gửi sự kiện vào Kafka. Sau đó cả 3 Node cùng đọc sự kiện từ Kafka và cập nhật RAM giống nhau.

---

### Kịch bản 2: Mô phỏng lỗi riêng Node C

Mục tiêu: Chứng minh hệ thống không bị dừng khi một Node bị lỗi.

Các bước thực hiện:

1. Đảm bảo hệ thống đang chạy đủ 3 Node.
2. Tắt riêng Node C bằng file:

```text
stop-node-c.bat
```

Nếu click đúp không tắt được, hãy chuột phải vào file và chọn:

```text
Run as Administrator
```

3. Quan sát Dashboard, Node C sẽ báo lỗi hoặc mất kết nối.
4. Trong lúc Node C đang tắt, tiếp tục gửi hành động mới ở Node A:

```text
WIN_MATCH
```

với số điểm:

```text
200
```

Kết quả mong đợi:

- Node A vẫn hoạt động.
- Node B vẫn hoạt động.
- Node C bị lỗi nên chưa cập nhật.
- Điểm của Node A và Node B tăng lên thành `300`.
- Hệ thống không bị dừng toàn bộ.

Giải thích:

Đây là tính chất **Non-blocking**. Khi Node C bị lỗi, Node A và Node B vẫn tiếp tục xử lý dữ liệu bình thường.

---

### Kịch bản 3: Khôi phục Node C

Mục tiêu: Chứng minh Node bị lỗi có thể tự đồng bộ lại dữ liệu.

Các bước thực hiện:

1. Chạy lại Node C bằng file:

```text
run-node-c.bat
```

2. Quay lại Dashboard.
3. Quan sát trạng thái Node C.
4. Nếu Dashboard có nút đo thời gian khôi phục, bấm vào nút:

```text
Bấm vào đây
```

Kết quả mong đợi:

- Node C chạy lại thành công.
- Node C đọc file Snapshot cũ.
- Node C kết nối lại Kafka.
- Node C xử lý lại các sự kiện bị bỏ lỡ.
- Điểm của Node C tự tăng từ `100` lên `300`.
- Cuối cùng, Node A, Node B và Node C lại có điểm giống nhau.

Giải thích:

Node C sử dụng cơ chế **Log-based Recovery**.

Nó đọc lại trạng thái gần nhất từ file Snapshot, sau đó dùng Kafka để Replay những sự kiện có Offset mới hơn. Nhờ vậy Node C có thể đuổi kịp trạng thái hiện tại của hệ thống.

---

### Kịch bản 4: Kiểm tra Snapshot Chandy-Lamport

Mục tiêu: Chứng minh hệ thống có thể lưu trạng thái toàn cục nhất quán.

Các bước thực hiện:

1. Sau khi hệ thống chạy một thời gian, quay lại thư mục gốc dự án.
2. Tìm các file:

```text
snapshot_8081.txt
snapshot_8082.txt
snapshot_8083.txt
```

3. Mở các file này để xem nội dung.

Kết quả mong đợi:

- Mỗi Node đều có file Snapshot riêng.
- File Snapshot lưu Offset hiện tại.
- File Snapshot lưu bảng điểm trong RAM.
- Các Snapshot giúp Node có thể khôi phục sau khi bị lỗi.

Giải thích:

Thuật toán Chandy-Lamport giúp hệ thống ghi lại trạng thái nhất quán mà không cần dừng các Node đang chạy.

---

## 12. Hướng dẫn reset dữ liệu

Sau khi test xong, nếu muốn xóa toàn bộ dữ liệu cũ để bắt đầu vòng demo mới, làm như sau.

### Bước 1: Tắt toàn bộ Node

Click đúp vào file:

```text
stop-3-nodes.bat
```

Nếu không tắt được, hãy chuột phải vào file và chọn:

```text
Run as Administrator
```

---

### Bước 2: Reset hệ thống

Click đúp vào file:

```text
reset-system.bat
```

File này sẽ thực hiện:

- Xóa các file Snapshot cũ.
- Reset dữ liệu Kafka.
- Đưa hệ thống về trạng thái ban đầu.

---

### Bước 3: Chạy lại hệ thống

Sau khi reset xong, chạy lại:

```text
run-3-nodes.bat
```

---

## 13. Tắt hệ thống sau khi sử dụng

Khi không còn cần chạy hệ thống, nên tắt để tránh nặng máy.

### Tắt toàn bộ Node Java

```text
stop-3-nodes.bat
```

### Tắt Kafka và Zookeeper

```text
stop-kafka.bat
```

---


## 14. Công nghệ sử dụng

| Công nghệ | Vai trò |
|---|---|
| Java 17 | Ngôn ngữ lập trình Backend |
| Spring Boot | Framework xây dựng REST API và xử lý nghiệp vụ |
| Spring Kafka | Kết nối Spring Boot với Apache Kafka |
| Apache Kafka | Message Broker, lưu log sự kiện điểm số |
| Apache Zookeeper | Quản lý metadata cho Kafka |
| Docker Compose | Khởi động Kafka và Zookeeper nhanh chóng |
| HTML/CSS/JavaScript | Xây dựng Dashboard giám sát |
| ConcurrentHashMap | Lưu bảng điểm trong RAM an toàn đa luồng |
| Batch Script / PowerShell | Tự động hóa chạy, tắt và reset hệ thống |

---

## 15. Các điểm nổi bật của dự án

- Đồng bộ điểm số thời gian thực giữa 3 Node.
- Mô phỏng hệ thống phân tán bằng nhiều tiến trình Spring Boot.
- Sử dụng Kafka làm trục truyền thông điệp.
- Áp dụng thuật toán Chandy-Lamport để chụp Snapshot.
- Có khả năng chịu lỗi khi một Node bị tắt.
- Có khả năng khôi phục dữ liệu bằng Snapshot và Kafka Replay Log.
- Có Dashboard trực quan để quan sát trạng thái hệ thống.
- Có bộ file `.bat` hỗ trợ chạy nhanh, tắt riêng từng Node và reset nhanh.
- Phù hợp để quay video demo 3 - 5 phút cho đồ án môn học.

---

## 16. Lỗi thường gặp và cách xử lý

### Lỗi 1: Dashboard báo Node Offline

Nguyên nhân có thể là Node chưa chạy hoặc Spring Boot chưa khởi động xong.

Cách xử lý:

- Đợi thêm 15 - 20 giây.
- Kiểm tra cửa sổ terminal của Node A, B, C.
- Chạy lại file `run-3-nodes.bat`.

---

### Lỗi 2: Kafka chưa kết nối được

Nguyên nhân có thể là Docker chưa chạy hoặc Kafka chưa khởi động xong.

Cách xử lý:

- Mở Docker Desktop.
- Chạy lại `start-kafka.bat`.
- Chờ khoảng 20 giây.
- Sau đó chạy lại các Node.

---

### Lỗi 3: Cổng 8081, 8082, 8083 bị chiếm

Nguyên nhân là tiến trình Java cũ chưa tắt hoàn toàn.

Cách xử lý:

```text
stop-3-nodes.bat
```

Nếu vẫn không tắt được, hãy chạy file này bằng quyền Admin:

```text
Chuột phải vào stop-3-nodes.bat -> Run as Administrator
```

Sau đó chạy lại:

```text
run-3-nodes.bat
```

---

### Lỗi 4: File stop-node không tắt được Node

Nguyên nhân có thể là Windows không cho script PowerShell tắt tiến trình nếu không có quyền đủ cao.

Cách xử lý:

```text
Chuột phải vào stop-node-a.bat / stop-node-b.bat / stop-node-c.bat
Chọn Run as Administrator
```

---

### Lỗi 5: Dữ liệu cũ vẫn còn sau khi test

Nguyên nhân là file Snapshot hoặc dữ liệu Kafka cũ vẫn còn.

Cách xử lý:

```text
reset-system.bat
```

Sau đó chạy lại hệ thống từ đầu:

```text
run-3-nodes.bat
```


## 17. Kết luận

Dự án đã mô phỏng thành công một hệ thống cơ sở dữ liệu phân tán ở mức ứng dụng, trong đó dữ liệu điểm số được đồng bộ giữa nhiều Node thông qua Apache Kafka.

Hệ thống chứng minh được các nội dung quan trọng của môn học:

- Đồng bộ dữ liệu giữa các bản sao.
- Xử lý sự kiện theo thứ tự.
- Chịu lỗi khi một Node bị sập.
- Khôi phục dữ liệu sau lỗi.
- Chụp trạng thái toàn cục nhất quán bằng thuật toán Chandy-Lamport.

Đây là minh chứng thực tế cho việc áp dụng lý thuyết hệ phân tán vào bài toán đồng bộ điểm số trò chơi theo thời gian thực.
