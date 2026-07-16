# 容器生命周期

## 一、容器状态流转
镜像 → docker create → Created → docker start → Running → docker stop → Exited → docker rm → Removed

↑                                            ↓

docker run（create+start）                  docker restart

↓

Running → docker pause → Paused → docker unpause → Running

↓

Running → docker kill → Exited（强制）

## 二、创建与启动

### 创建容器（不启动）
bash

docker create --name my-nginx nginx:latest

### 创建并启动（最常用）
bash

docker run -d --name my-nginx -p 8080:80 nginx:latest

常用选项：
- `-d`：后台运行
- `--name`：指定容器名
- `-p`：端口映射（宿主机:容器）
- `-v`：挂载数据卷
- `-e`：设置环境变量
- `--restart`：重启策略
- `--network`：指定网络
- `--memory`：内存限制
- `--cpus`：CPU 限制

### 交互式运行
bash

docker run -it --name ubuntu-box ubuntu:22.04 /bin/bash

## 三、启动、停止、重启
bash

启动已创建的容器
docker start my-nginx

停止容器（发送 SIGTERM，等待超时后 SIGKILL）
docker stop my-nginx

强制停止（直接 SIGKILL）
docker kill my-nginx

重启容器
docker restart my-nginx

## 四、暂停与恢复
bash

暂停容器（冻结进程）
docker pause my-nginx

恢复暂停的容器
docker unpause my-nginx

## 五、删除容器
bash

删除已停止的容器
docker rm my-nginx

强制删除运行中的容器
docker rm -f my-nginx

删除所有已停止的容器
docker container prune

删除所有容器（包括运行中的，谨慎）
docker rm -f $(docker ps -aq)

## 六、进入容器
bash

在容器中执行命令（推荐）
docker exec -it my-nginx /bin/bash

附着到容器的主进程（不常用，exit 会停止容器）
docker attach my-nginx

## 七、查看容器
bash

列出运行中的容器
docker ps

列出所有容器（包括停止的）
docker ps -a

查看容器详细信息
docker inspect my-nginx

查看容器进程
docker top my-nginx

---

## 小结

- 容器生命周期：create → start → stop → rm。
- `docker run` 是最常用的命令，组合了 create 和 start。
- 学会使用 `exec` 进入容器调试。
- 注意 `pause` 和 `stop` 的区别：pause 冻结进程，stop 发送信号优雅退出。