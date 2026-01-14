#!/usr/bin/env php
<?php

/**
 * moda.STUDIO 测试数据生成工具
 */

require_once __DIR__ . '/server/bootstrap/autoload.php';

use Faker\Factory as Faker;
use Illuminate\Database\Capsule\Manager as DB;

class TestDataGenerator
{
    protected $faker;
    protected $db;

    public function __construct()
    {
        $this->faker = Faker::create('zh_CN');
    }

    /**
     * 生成测试用户
     */
    public function generateUsers($count = 10)
    {
        echo "生成 {$count} 个测试用户...\n";
        
        $users = [];
        for ($i = 0; $i < $count; $i++) {
            $users[] = [
                'name' => $this->faker->name(),
                'email' => $this->faker->unique()->safeEmail(),
                'password' => bcrypt('password123'),
                'phone' => $this->faker->phoneNumber(),
                'avatar' => $this->faker->imageUrl(200, 200, 'people', false),
                'created_at' => now(),
                'updated_at' => now(),
            ];
        }
        
        echo "✅ 已生成 {$count} 个用户\n";
        return $users;
    }

    /**
     * 生成测试聊天机器人
     */
    public function generateChatbots($count = 5, $userId = 1)
    {
        echo "生成 {$count} 个测试聊天机器人...\n";
        
        $models = ['gpt-4-turbo', 'gpt-3.5-turbo', 'claude-3-opus', 'gemini-pro'];
        $bots = [];
        
        for ($i = 0; $i < $count; $i++) {
            $bots[] = [
                'user_id' => $userId,
                'name' => $this->faker->sentence(3),
                'slug' => str_slug($this->faker->sentence(3)),
                'description' => $this->faker->paragraph(2),
                'model' => $this->faker->randomElement($models),
                'instructions' => $this->faker->paragraph(5),
                'temperature' => $this->faker->randomFloat(2, 0, 2),
                'max_tokens' => $this->faker->randomElement([256, 512, 1024, 2048]),
                'status' => 'active',
                'created_at' => now(),
                'updated_at' => now(),
            ];
        }
        
        echo "✅ 已生成 {$count} 个聊天机器人\n";
        return $bots;
    }

    /**
     * 生成测试聊天历史
     */
    public function generateChatHistory($chatbotId, $count = 20)
    {
        echo "生成 {$count} 条对话记录...\n";
        
        $questions = [
            '人工智能的未来是什么？',
            '如何学习编程？',
            '最好的编程语言是什么？',
            '云计算有什么优势？',
            '区块链技术应该用在哪里？',
            '如何开始创业？',
            '什么是深度学习？',
            '数据科学的应用前景如何？',
            '如何写好一篇文章？',
            '如何提高工作效率？',
        ];
        
        $histories = [];
        for ($i = 0; $i < $count; $i++) {
            $histories[] = [
                'chatbot_id' => $chatbotId,
                'user_message' => $this->faker->randomElement($questions),
                'bot_response' => $this->faker->paragraph(3),
                'tokens_used' => $this->faker->numberBetween(100, 500),
                'created_at' => now()->subDays($count - $i),
                'updated_at' => now()->subDays($count - $i),
            ];
        }
        
        echo "✅ 已生成 {$count} 条对话记录\n";
        return $histories;
    }

    /**
     * 生成测试文章
     */
    public function generateArticles($count = 15)
    {
        echo "生成 {$count} 篇测试文章...\n";
        
        $categories = ['AI', '编程', '设计', '营销', '创业'];
        $articles = [];
        
        for ($i = 0; $i < $count; $i++) {
            $articles[] = [
                'title' => $this->faker->sentence(6),
                'slug' => str_slug($this->faker->sentence(6)),
                'category' => $this->faker->randomElement($categories),
                'content' => $this->faker->paragraph(10),
                'excerpt' => $this->faker->paragraph(2),
                'image' => $this->faker->imageUrl(800, 400),
                'author' => $this->faker->name(),
                'views' => $this->faker->numberBetween(0, 10000),
                'published' => true,
                'published_at' => now()->subDays($count - $i),
                'created_at' => now(),
                'updated_at' => now(),
            ];
        }
        
        echo "✅ 已生成 {$count} 篇文章\n";
        return $articles;
    }

    /**
     * 生成 AI 工具使用日志
     */
    public function generateAiToolUsageLogs($count = 100)
    {
        echo "生成 {$count} 条 AI 工具使用日志...\n";
        
        $statuses = ['completed', 'failed', 'pending'];
        $logs = [];
        
        for ($i = 0; $i < $count; $i++) {
            $logs[] = [
                'user_id' => $this->faker->numberBetween(1, 10),
                'ai_tool_id' => $this->faker->numberBetween(1, 36),
                'input' => json_encode(['query' => $this->faker->sentence()]),
                'output' => json_encode(['result' => $this->faker->paragraph()]),
                'tokens_used' => $this->faker->numberBetween(50, 500),
                'cost' => $this->faker->randomFloat(4, 0, 1),
                'status' => $this->faker->randomElement($statuses),
                'execution_time_ms' => $this->faker->numberBetween(100, 5000),
                'created_at' => now()->subDays(30)->addSeconds($i * 86400 / $count),
                'updated_at' => now(),
            ];
        }
        
        echo "✅ 已生成 {$count} 条使用日志\n";
        return $logs;
    }

    /**
     * 生成订阅计划
     */
    public function generatePlans()
    {
        echo "生成订阅计划...\n";
        
        $plans = [
            [
                'name' => '免费版',
                'slug' => 'free',
                'description' => '适合个人使用',
                'price' => 0,
                'interval' => 'month',
                'features' => json_encode([
                    'ai_tools' => 5,
                    'chatbots' => 2,
                    'storage' => '5GB',
                ]),
                'position' => 1,
            ],
            [
                'name' => '专业版',
                'slug' => 'pro',
                'description' => '适合小团队',
                'price' => 99,
                'interval' => 'month',
                'features' => json_encode([
                    'ai_tools' => 20,
                    'chatbots' => 10,
                    'storage' => '100GB',
                ]),
                'position' => 2,
            ],
            [
                'name' => '企业版',
                'slug' => 'enterprise',
                'description' => '适合大型企业',
                'price' => 499,
                'interval' => 'month',
                'features' => json_encode([
                    'ai_tools' => -1,  // 无限
                    'chatbots' => -1,
                    'storage' => '无限',
                ]),
                'position' => 3,
            ],
        ];
        
        echo "✅ 已生成 3 个订阅计划\n";
        return $plans;
    }

    /**
     * 运行所有生成器
     */
    public function run()
    {
        echo "\n" . str_repeat("=", 50) . "\n";
        echo "  moda.STUDIO 测试数据生成工具\n";
        echo str_repeat("=", 50) . "\n\n";

        try {
            // 生成用户
            $this->generateUsers(5);
            
            // 生成聊天机器人
            $this->generateChatbots(3, 1);
            
            // 生成聊天历史
            $this->generateChatHistory(1, 20);
            
            // 生成文章
            $this->generateArticles(10);
            
            // 生成 AI 工具使用日志
            $this->generateAiToolUsageLogs(50);
            
            // 生成订阅计划
            $this->generatePlans();
            
            echo "\n" . str_repeat("=", 50) . "\n";
            echo "✅ 测试数据生成完成！\n";
            echo str_repeat("=", 50) . "\n\n";
            
        } catch (\Exception $e) {
            echo "❌ 错误: " . $e->getMessage() . "\n";
            exit(1);
        }
    }
}

// 运行生成器
if (php_sapi_name() === 'cli') {
    $generator = new TestDataGenerator();
    $generator->run();
}
