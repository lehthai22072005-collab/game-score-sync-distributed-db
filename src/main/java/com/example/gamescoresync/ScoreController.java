package com.example.gamescoresync;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.web.bind.annotation.*;
import java.util.Map;

@RestController
@RequestMapping("/api")
public class ScoreController {

    @Autowired
    private ScoreService scoreService;

    @Autowired
    private KafkaTemplate<String, String> kafkaTemplate;

    // LẤY ĐIỂM: Để Dashboard gọi vào (GET http://localhost:8081/api/scores)
    @GetMapping("/scores")
    public Map<String, Integer> getAllScores() {
        return scoreService.getScoreBoard();
    }

    // GỬI ĐIỂM: Để Postman gọi vào (POST http://localhost:8081/api/scores)
    @PostMapping("/scores")
    public String receiveScore(@RequestBody Map<String, Object> payload) {
        // Gửi dữ liệu vào Kafka - Nhớ dùng đúng version topic bạn đang chạy (v3 hoặc v1)
        kafkaTemplate.send("player-actions-v1", payload.toString());

        System.out.println("🚀 Node nhận dữ liệu và đẩy vào Kafka: " + payload);
        return "Gửi dữ liệu thành công!";
    }
}