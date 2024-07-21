# 1. 协议
## 1.1. 异步协议
类似 MPI。每个标有 `async` 的函数 `foo(...)` ，将提供几个变体：
- `bool foo(&req, int timeoutMillisecs)`：非阻塞地启动一个函数，将句柄保存在 `req` 中，返回值为是否成功启动
- `bool cancel(req, blocking=true/false)`：立刻终止该函数，`blocking=true`时等待函数真正停止了再返回。返回值为是否停止成功
- `Status status(req)`：返回 `req` 是否已完成、正在运行、已错误或已终止
- `Status wait(req, &ret)`：阻塞至 `req` 完成，将返回值保存在 `ret` 中。返回值为是否成功获取返回值。

对于 Flutter 等有桥实现（`flutter_rust_bridge`）的，会尝试不用以上过程。

### 结构体
- `Status`

## 1.2. 进度协议
标有 `progress` 的 `async` 函数能够获取其进度。将提供：

- `double progress(req)`：获取当前进度百分比。若不可用（如 `req` 已经停止，或暂时无法估算进度）则为 `NaN`

## 1.3. 流协议
标有 `stream` 的函数参数需要流式传输。

- `int foo_send(req, byte[] newBytes, int n)`：发送接下来的字节给函数 `foo(&req)` 调用。若 `newBytes.length == 0`，则视为发送结束，成功则返回 0。返回成功发送的字节数（若发送已终止/失败，返回 -1）

标有 `stream` 的返回值需要流式传输。

- `int foo_recv(req, &byte[] newBytes, int n)`：接受指定字节数到 `newBytes` 中。（若接收已终止（EOF 或 cancel）或失败，返回 -1）

Flutter 中，利用 flutter_rust_bridge 的 `StreamSink` 绑定即可完成。

# 2. 接口
## 2.1. 发现
### 函数
- `device_init(Device thisDevice)`：初始化当前设备信息
- `async Device[] discover(DiscoverMethod[] methods)`
### 结构体
- `Device`
- `DiscoverMethod`

## 2.2. 传输
### 函数
- `async progress int send(Device receiver, stream byteData)`
- `async progress stream recv(Device sender)`
