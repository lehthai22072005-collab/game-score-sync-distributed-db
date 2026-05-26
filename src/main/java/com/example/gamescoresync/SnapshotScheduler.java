package com.example.gamescoresync;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Configuration;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.scheduling.annotation.EnableScheduling;
import org.springframework.scheduling.annotation.Scheduled;

@Configuration
@EnableScheduling
public class SnapshotScheduler {

    @Autowired
    private KafkaTemplate<String, String> kafkaTemplate;

    // Cứ 10 giây (10000 ms) hàm này sẽ tự chạy 1 lần
    @Scheduled(fixedRate = 10000)
    public void triggerChandyLamportSnapshot() {
        // Chỉ cho phép Node 8081 làm Master phát lệnh Marker để tránh bị gửi trùng 3 lần
        String port = System.getProperty("server.port", "8081");
        if ("8081".equals(port)) {
            System.out.println("⏱️ [AUTO 10s] Master Node đang phát lệnh MARKER (Chandy-Lamport)...");
            kafkaTemplate.send("player-actions-v1", "{\"actionType\":\"MARKER\"}");
        }
    }
}