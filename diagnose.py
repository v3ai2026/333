#!/usr/bin/env python3
"""
moda.STUDIO 系统监控和诊断工具
"""

import subprocess
import sys
import requests
from datetime import datetime
from pathlib import Path


class ModaStudioDiagnostics:
    def __init__(self):
        self.results = {}
        self.timestamp = datetime.now().isoformat()

    def check_port(self, port, name):
        """检查端口是否开放"""
        try:
            import socket
            sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            sock.settimeout(1)
            result = sock.connect_ex(('localhost', port))
            sock.close()
            return result == 0
        except Exception:
            return False

    def check_service(self, url, name, timeout=5):
        """检查服务是否可访问"""
        try:
            response = requests.get(url, timeout=timeout)
            return response.status_code < 500
        except Exception:
            return False

    def run_diagnostics(self):
        """运行完整诊断"""
        print("\n" + "=" * 50)
        print("  moda.STUDIO 系统诊断工具")
        print("=" * 50)
        print(f"诊断时间: {self.timestamp}\n")

        # 检查各个端点
        endpoints = [
            (3306, "MySQL", None),
            (6379, "Redis", None),
            (8000, "Laravel", "http://localhost:8000"),
            (8080, "Python", "http://localhost:8080"),
        ]

        results = []

        for port, name, url in endpoints:
            print(f"检查 {name} ({port})...", end=" ")

            port_open = self.check_port(port, name)

            if port_open and url:
                service_ok = self.check_service(url, name)
                status = "✅ 运行中" if service_ok else "⚠️  端口开放但服务异常"
            elif port_open:
                status = "✅ 端口开放"
            else:
                status = "❌ 未运行"

            print(status)
            results.append({
                "name": name,
                "port": port,
                "status": status
            })

        # 检查文件
        print("\n检查关键文件...")
        files = [
            "server/.env",
            "server/composer.lock",
            "backend-service/requirements.txt",
            "magicai.sql",
        ]

        for file_path in files:
            exists = Path(file_path).exists()
            status = "✅" if exists else "❌"
            print(f"  {status} {file_path}")

        # 检查 Git
        print("\n检查 Git 仓库...")
        try:
            result = subprocess.run(
                ["git", "status"],
                cwd=".",
                capture_output=True,
                text=True,
                timeout=5
            )
            if result.returncode == 0:
                print("  ✅ Git 仓库已初始化")
                # 显示分支
                branch_result = subprocess.run(
                    ["git", "rev-parse", "--abbrev-ref", "HEAD"],
                    cwd=".",
                    capture_output=True,
                    text=True,
                    timeout=5
                )
                branch = branch_result.stdout.strip()
                print(f"  📁 当前分支: {branch}")
            else:
                print("  ⚠️  Git 仓库初始化失败")
        except Exception:
            print("  ⚠️  Git 不可用")

        # 总结
        print("\n" + "=" * 50)
        print("  诊断总结")
        print("=" * 50)

        running = sum(1 for r in results if "✅" in r["status"])
        total = len(results)

        print(f"\n运行中的服务: {running}/{total}")

        if running == total:
            print("✅ 所有服务正常运行！")
            return True
        else:
            print("⚠️  某些服务未运行，请检查日志")
            print("\n快速启动命令:")
            print("  Docker: docker-compose -f docker-compose.prod.yml up -d")
            print("  Windows: startup.bat")
            print("  Linux/Mac: ./startup.sh")
            return False


def main():
    diag = ModaStudioDiagnostics()
    success = diag.run_diagnostics()
    sys.exit(0 if success else 1)


if __name__ == "__main__":
    main()
