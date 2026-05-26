package com.example.gamescoresync;

import jakarta.annotation.PostConstruct;
import org.springframework.stereotype.Service;
import java.io.*;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.Map; // THÊM DÒNG NÀY
import java.util.concurrent.ConcurrentHashMap;

@Service
public class ScoreService {
    // RAM lưu điểm
    private ConcurrentHashMap<String, Integer> scoreBoard = new ConcurrentHashMap<>();

    // Lưu lại số thứ tự tin nhắn cuối cùng đã xử lý (Channel State của Chandy-Lamport)
    private long lastProcessedOffset = -1;

    // Đọc tên file snapshot dựa vào port để mỗi Node có 1 file riêng (vd: snapshot_8081.txt)
    private String getSnapshotFileName() {
        String port = System.getProperty("server.port", "8081");
        return "snapshot_" + port + ".txt";
    }


    @PostConstruct
    public void recoverFromSnapshot() {
        File file = new File(getSnapshotFileName());
        if (file.exists()) {
            // Bắt đầu bấm giờ
            long startTime = System.currentTimeMillis();

            try {
                String content = new String(Files.readAllBytes(Paths.get(getSnapshotFileName())));
                String[] parts = content.split("\\|");
                lastProcessedOffset = Long.parseLong(parts[0].trim());

                String mapData = parts[1].replace("{", "").replace("}", "").trim();
                if (!mapData.isEmpty()) {
                    String[] entries = mapData.split(",");
                    for (String entry : entries) {
                        String[] kv = entry.split("=");
                        scoreBoard.put(kv[0].trim(), Integer.parseInt(kv[1].trim()));
                    }
                }

                // Kết thúc bấm giờ sau khi nạp xong RAM
                long endTime = System.currentTimeMillis();
                long recoveryTime = endTime - startTime;

                System.out.println("🔄 --- HỆ THỐNG ĐÃ PHỤC HỒI ---");
                System.out.println("💾 Bảng điểm nạp lại: " + scoreBoard);
                System.out.println("⏱️ Thời gian phục hồi (Recovery Time): " + recoveryTime + " ms");
                System.out.println("-------------------------------");

            } catch (Exception e) {
                System.out.println("⚠️ Lỗi khôi phục: " + e.getMessage());
            }
        }
    }

    public void processAction(String playerId, String actionType, int points, long offset) {
        // Thuật toán: Chỉ cộng điểm nếu tin nhắn này là MỚI (chưa có trong snapshot)
        if (offset <= lastProcessedOffset) {
            System.out.println("⏩ Bỏ qua tin nhắn cũ (Offset " + offset + ") vì đã có trong Snapshot.");
            return;
        }

        // Xử lý ActionType theo đề tài
        int currentScore = scoreBoard.getOrDefault(playerId, 0);
        if ("KILL_MONSTER".equals(actionType) || "WIN_MATCH".equals(actionType)) {
            scoreBoard.put(playerId, currentScore + points);
        } else if ("LOSE_MATCH".equals(actionType)) {
            scoreBoard.put(playerId, Math.max(0, currentScore - points));
        }

        lastProcessedOffset = offset;
        System.out.println("📊 TRẠNG THÁI (Offset " + offset + "): " + scoreBoard);
    }

    // Thuật toán Chandy-Lamport: Ghi trạng thái RAM và Offset ra file
    public void saveSnapshot(long currentOffset) {
        try (FileWriter writer = new FileWriter(getSnapshotFileName())) {
            // Ghi Offset và RAM ra file
            writer.write(currentOffset + "|" + scoreBoard.toString());
            System.out.println("✅ (Chandy-Lamport) Đã chụp Snapshot tại Offset: " + currentOffset);
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    // SỬA LẠI HÀM NÀY: Trả về Map chuẩn của java.util
    public Map<String, Integer> getScoreBoard() {
        return this.scoreBoard;
    }
}