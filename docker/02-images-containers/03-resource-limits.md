# 资源限制与重启策略

## 一、为什么需要资源限制？

- 防止单个容器占用全部 CPU 或内存，影响其他容器。
- 保证服务质量，避免 OOM。
- 合理分配资源，提高部署密度。

## 二、内存限制
bash

限制最大内存 512MB，禁止使用 swap
docker run -d --memory=512m --memory-swap=512m nginx

限制最大内存 1GB，允许使用 swap（最多 1GB）
docker run -d --memory=1g --memory-swap=2g nginx

查看内存限制是否生效
docker inspect my-nginx | grep Memory

参数说明：
- `--memory`：最大内存限制。
- `--memory-swap`：内存+swap 的总限制。如果等于 `--memory`，则禁用 swap。
- `--memory-reservation`：软限制，尽力保证不超过此值。

## 三、CPU 限制
bash

限制使用 1.5 个 CPU 核心
docker run -d --cpus=1.5 nginx

限制 CPU 份额（相对权重，默认 1024）
docker run -d --cpu-shares=512 nginx

绑定到特定 CPU 核心
docker run -d --cpuset-cpus=0,2 nginx

参数说明：
- `--cpus`：限制使用的 CPU 核心数（如 1.5 表示 1.5 核）。
- `--cpu-shares`：相对权重，值越高获得更多 CPU 时间。
- `--cpuset-cpus`：绑定到指定 CPU 核心（从 0 开始）。

## 四、磁盘 IO 限制
bash

限制读写 IOPS
docker run -d --device-read-iops=/dev/sda:1000 --device-write-iops=/dev/sda:500 nginx

限制读写带宽（字节/秒）
docker run -d --device-read-bps=/dev/sda:50mb --device-write-bps=/dev/sda:20mb nginx

## 五、重启策略
bash

不自动重启（默认）
docker run -d --restart=no nginx

容器退出时总是重启（除非手动停止）
docker run -d --restart=always nginx

退出时重启，最多尝试 5 次
docker run -d --restart=on-failure:5 nginx

除非手动停止，否则一直重启（类似 always，但 daemon 重启后也重启）
docker run -d --restart=unless-stopped nginx

## 六、查看资源使用
bash

实时查看容器资源使用
docker stats

查看单个容器
docker stats my-nginx

查看容器资源限制配置
docker inspect my-nginx | grep -A 10 "HostConfig"

---

## 小结

- 生产环境必须设置资源限制，防止资源争抢。
- 内存限制用 `--memory`，CPU 限制用 `--cpus`。
- 重启策略根据业务需求选择，通常用 `always` 或 `unless-stopped`。
- 使用 `docker stats` 监控资源使用情况。