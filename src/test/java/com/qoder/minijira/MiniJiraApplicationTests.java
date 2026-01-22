package com.qoder.minijira;

import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.ActiveProfiles;

/**
 * 应用启动测试
 * 确保 Spring 上下文能够正常加载
 */
@SpringBootTest
@ActiveProfiles("test")
class MiniJiraApplicationTests {

    @Test
    void contextLoads() {
        // 测试 Spring 上下文是否正常加载
    }

}
