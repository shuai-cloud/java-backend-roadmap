import java.io.*;
import java.nio.ByteBuffer;
import java.nio.channels.FileChannel;

/**
 * FileChannel 演示
 */
public class FileChannelDemo {
    public static void main(String[] args) throws IOException {
        File file = new File("/tmp/channel.txt");

        // 写入
        try (RandomAccessFile raf = new RandomAccessFile(file, "rw");
             FileChannel channel = raf.getChannel()) {

            ByteBuffer buffer = ByteBuffer.allocate(1024);
            buffer.put("Hello, FileChannel!".getBytes());
            buffer.flip();
            channel.write(buffer);
        }

        // 读取
        try (RandomAccessFile raf = new RandomAccessFile(file, "r");
             FileChannel channel = raf.getChannel()) {

            ByteBuffer buffer = ByteBuffer.allocate(1024);
            int bytesRead = channel.read(buffer);
            buffer.flip();
            byte[] data = new byte[bytesRead];
            buffer.get(data);
            System.out.println("Read: " + new String(data));
        }

        // 零拷贝传输（transferTo）
        File dest = new File("/tmp/channel_copy.txt");
        try (FileChannel srcChannel = new FileInputStream(file).getChannel();
             FileChannel destChannel = new FileOutputStream(dest).getChannel()) {
            srcChannel.transferTo(0, srcChannel.size(), destChannel);
        }
        System.out.println("Copied via transferTo");

        file.delete();
        dest.delete();
    }
}