#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "debug.h"
#include "linkData.h"

/*
 * copy value to struct data
 */
int linkDataAdd_1(void *value, void **data)
{
	Data	*temp;

	temp = (Data *)calloc(1, sizeof(Data));
	if(NULL == temp)
	{
		debug("calloc failed!\n");
		return -1;
	}
	memcpy(temp, value, sizeof(Data));
	*(Data **)data = temp;
	return 0;
}



/*
 * get value from node
 */
int linkDataGetValue_1(void *data, void *result)
{
	strcpy((char *)result, (char *)((Data *)data)->filename);
	printf("%s", (char *)result);
	return 0;
}

/*
 * show data of one node
 */
int linkDataShow_1(void *data, void *result)
{
	printf("%s", ((Data *)data)->filename);
	return 0;
}



/*
 * function to compare data
 */
int linkDataCompare_1(void *data1, void *data2)
{
	return strcasecmp(((Data *)data1)->filename,((Data *)data2)->filename);
}



/*
 * free the link
 */
int linkDataFree_1(void *data)
{
	free((Data *)data);
	return 0;
}

