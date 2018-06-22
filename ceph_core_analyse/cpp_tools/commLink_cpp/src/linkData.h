#ifndef _LINKDATA_H_
#define _LINKDATA_H_

typedef struct data
{
	char	filename[128];
}Data;

//copy value to struct data
int linkDataAdd_1(void *value, void **data);
int linkDataGetValue_1(void *data, void *result);
int linkDataShow_1(void *, void *);
int linkDataCompare_1(void *, void *);
int linkDataFree_1(void *);

#endif
