# 日志与监控

## 一、查看容器日志
bash

查看全部日志
docker logs my-nginx

实时跟踪日志（类似 tail -f）
docker logs -f my-nginx

查看最后 100 行
docker logs --tail 100 my-nginx

显示时间戳
docker logs -t my-nginx

查看指定时间段的日志
docker logs --since 2025-01-01T00:00:00 --until 2025-01-02T00:00:00 my-nginx

## 二、日志驱动

Docker 支持多种日志驱动，默认是 `json-file`（写入宿主机文件）。常用驱动：

| 驱动 | 说明 | 适用场景 |
|------|------|----------|
| `json-file` | 默认，写入宿主机文件 | 单机开发测试 |
| `journald` | 写入 systemd journal | Linux 系统 |
| `syslog` | 写入 syslog | 集中日志收集 |
| `fluentd` | 发送到 Fluentd | 日志聚合 |
| `awslogs` | 发送到 CloudWatch | AWS 环境 |
| `gelf` | 发送到 Graylog | 集中日志 |
| `none` | 不记录日志 | 性能敏感场景 |

配置日志驱动（全局）：
json

{

"log-driver": "json-file",

"log-opts": {

"max-size": "10m",

"max-file": "3"

}

}

配置日志驱动（容器级别）：
bash

docker run -d --log-driver json-file --log-opt max-size=10m --log-opt max-file=3 nginx

## 三、监控容器资源
bash

实时查看所有容器的 CPU、内存、网络、磁盘 IO
docker stats

只查看某个容器
docker stats my-nginx

以 JSON 格式输出
docker stats --no-stream --format "{{.Name}}: {{.CPUPerc}} {{.MemUsage}}"

## 四、查看容器事件
bash

实时查看 Docker 事件（创建、启动、停止等）
docker events

查看指定容器的事件
docker events --filter container=my-nginx

查看指定类型的事件
docker events --filter event=start --filter event=stop

## 五、容器内进程查看
bash

查看容器内运行的进程
docker top my-nginx

进入容器查看进程
docker exec -it my-nginx ps aux

## 六、健康检查

Dockerfile 中定义健康检查：
dockerfile

HEALTHCHECK --interval=30s --timeout=3s --retries=3 \

CMD curl -f http://localhost:8080/health|| exit 1

运行时覆盖：
bash

docker run --health-cmd="curl -f http://localhost:8080/health" \

--health-interval=30s \

--health-timeout=3s \

--health-retries=3 \

nginx

查看健康状态：
bash

docker inspect my-nginx | grep Health

---

## 小结

- 日志管理：合理配置日志驱动和轮转策略，避免磁盘写满。
- 监控：使用 `docker stats` 和 `docker events` 实时查看。
- 健康检查：让 Docker 自动检测容器是否正常工作。
- 生产环境建议将日志发送到集中式日志系统（如 ELK、Loki）。