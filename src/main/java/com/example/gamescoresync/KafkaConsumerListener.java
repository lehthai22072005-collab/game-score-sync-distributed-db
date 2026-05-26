package com.example.gamescoresync;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.kafka.support.KafkaHeaders;
import org.springframework.messaging.handler.annotation.Header;
import org.springframework.stereotype.Service;

@Service
public class KafkaConsumerListener {

    @Autowired
    private ScoreService scoreService;

    // Dùng random UUID để ép cơ chế Broadcast cho cả 3 Nodes
    @KafkaListener(topics = "player-actions-v12", groupId = "#{T(java.util.UUID).randomUUID().toString()}")
    public void consumeAction(String message, @Header(KafkaHeaders.OFFSET) long offset) {

        // 1. Nếu là lệnh chụp ảnh (Marker)
        if (message.contains("MARKER")) {
            System.out.println("🚩 NHẬN ĐƯỢC MARKER TỪ HỆ THỐNG!");
            scoreService.saveSnapshot(offset);
            return;
        }

        // 2. Nếu là sự kiện Game
        try {
            // Tách chuỗi theo đúng format {playerID=ThaiLe, actionType=KILL_MONSTER, points=100}
            String playerId = message.split("playerID=")[1].split(",")[0].trim();
            String actionType = message.split("actionType=")[1].split(",")[0].trim();
            String pointsStr = message.split("points=")[1].split("}")[0].trim();
            int points = Integer.parseInt(pointsStr);

            // Gọi service để cộng điểm
            scoreService.processAction(playerId, actionType, points, offset);

        } catch (Exception e) {
            // In ra để biết nếu có tin nhắn rác
            System.out.println("⚠️ Bỏ qua tin nhắn không hợp lệ: " + message);
        }
    }
}