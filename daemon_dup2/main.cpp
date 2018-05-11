#include "hello.h"
#include <unistd.h>
#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>



#define check_ret if(ret<0){printf("ret= %d\n", ret);return 0;}


int main(void){

    int fd = 0;
    int ret = 0;
    fd=open("/root/tmp.file",O_CREAT|O_RDWR|O_APPEND,0644);
    if(fd<0){
        printf("error open file\n");
        return 0;
        }
    printf("hello, fd=%d\n", fd);


    daemon(0,0);

    ret = dup2(fd,1);
    check_ret
    ret = dup2(fd,2);
    check_ret

    printf("hello, fd=%d\n", fd);

    hello();
    while(true){
        sleep(1);
        hello();
        };
    return 0;
}
