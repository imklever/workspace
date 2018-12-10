#include <stdio.h>
#include <cstdlib>
#include <string.h>
#include "commlink.h"
#include "linkData.h"
#include "debug.h"
#include "time.h"

using namespace std;

int main()
{
	Data		*data;
	char str[10];
	char str1[10];

	srand(time(NULL));


	for(int i=0;i<10;i++)
	{
		commlink *commInstance = new commlink();

		//debug("addLinkTail!\n");
		printf("getfro:");
		for(int j=0;j<100;j++)
		{
			int randi = rand();
			data = (Data *)malloc(sizeof(Data));
			sprintf(str,"%c", randi%26+'a');
			strcpy(data->filename, str);
			commInstance->addLinkTail((void *)data);
		}
		commInstance->ergodicLink(linkDataGetValue_1, str1);
		printf("\n");

		printf("before:");
		commInstance->ergodicLink(linkDataShow_1, NULL);
		printf("\n");

		//debug("linkSort!\n");
		commInstance->sortLink(linkDataCompare_1);

		printf("after :");
		commInstance->ergodicLink(linkDataShow_1, NULL);
		printf("\n");
		printf("\n");
		/*
		//debug("freeLink!\n");
		for(commInstance->set_begin(); commInstance->current()!=commInstance->get_header(); commInstance->next())
		{
			free(commInstance->current()->data);
		}
		*/
		
		delete commInstance;
		
	}

	return 0;
}
