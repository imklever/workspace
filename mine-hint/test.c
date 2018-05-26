#include <stdio.h>

#define N 3
#define M 4

int main()
{
    int i,j;
    int num=    0;
    int offset= 0;

    char *str="*.....*.....";
    int result[N][M]=   {0};

    for(i=0;i<N;i++)
    {
        for(j=0;j<M;j++)
        {
            //打印字符
            printf("%c", *(str+i*M+j));

            //当前节点是否为mine(炸弹)
            if(*(str+i*M+j)=='*')
            {
                result[i][j]=-1;
                continue;
            }

            //节点周边计算开始
            num=0;
            offset = (i-1)*M+j-1;
            if(i>0 && j>0 && *(str+offset)=='*')
                num += 1;
            offset = (i-1)*M+j;
            if(i>0 && *(str+offset)=='*')
                num += 1;
            offset = (i-1)*M+j+1;
            if(i>0 && j<(M-1) && *(str+offset)=='*')
                num += 1;

            offset = i*M+j-1;
            if(j>0 && *(str+offset)=='*')
                num += 1;
            offset = i*M+j+1;
            if(j<(M-1) && *(str+offset)=='*')
                num += 1;

            offset = (i+1)*M+j-1;
            if(i<(N-1) && j>0 && *(str+offset)=='*')
                num += 1;
            offset = (i+1)*M+j;
            if(i<(N-1) && *(str+offset)=='*')
                num += 1;
            offset = (i+1)*M+j+1;
            if(i<(N-1) && j<(M-1) && *(str+offset)=='*')
                num += 1;
            result[i][j]=num;
            //节点周边计算结束


        }
        printf("\n");
    }

    printf("-------------\n");


    //打印统计结果
    for(i=0;i<N;i++)
    {
        for(j=0;j<M;j++)
        {
            if(result[i][j]==-1)
                printf("*");
            else
                printf("%d", result[i][j]);
        }
        printf("\n");
    }

    return 0;
}
