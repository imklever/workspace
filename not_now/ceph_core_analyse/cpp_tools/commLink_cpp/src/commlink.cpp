#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include "debug.h"
#include "commlink.h"
#include "linkData.h"

using namespace std;


/*
 * function: constructor
 */
commlink::commlink(void)
{
	header = NULL;
	createLinkHead();
	cur_position = header;
	t_position = header;
	return ;
}



/*
 * function: destructor
 */
commlink::~commlink(void)
{
	freeLink();
	return ;
}



/*
 * function: create header node
 */
int commlink::createLinkHead(void)
{
	LinkNode *temp = NULL;
	temp = (LinkNode *)calloc(1, sizeof(LinkNode));
	if(NULL == temp)
	{
		debug("calloc failed!\n");
		return 1;
	}
	temp->prev = temp;
	temp->next = temp;
	temp->parent= NULL;
	temp->child= NULL;
	temp->data = NULL;
	header = temp;
	temp = NULL;
	
	return 0;
}



/*
 * function: add node at Tail
 */
//int commlink::addLinkTail(LinkNode *header, void *value, int (*func)(void *value, void **data))
int commlink::addLinkTail(void *value)
{
	int ret = 0;
	LinkNode *temp = NULL;

	temp = (LinkNode *)calloc(1, sizeof(LinkNode));
	if(NULL == temp)
	{
		debug("calloc failed!\n");
		return -1;
	}
	temp->prev = header->prev;
	temp->next = header;
	header->prev->next = temp;
	header->prev = temp;
	//ret = func(value, &(temp->data));
	header->prev->data = value;
	temp=NULL;
	return ret;
}



/*
 * function: add node at child tail
 */
//int commlink::addLinkTail(LinkNode *header, void *value, int (*func)(void *value, void **data))
int commlink::addLinkchildTail(LinkNode *parent, void *value)
{
	int ret = 0;
	LinkNode *temp = NULL;

	temp = (LinkNode *)calloc(1, sizeof(LinkNode));
	if(NULL == temp)
	{
		debug("calloc failed!\n");
		return -1;
	}
	temp->prev = header->prev;
	temp->next = header;
	header->prev->next = temp;
	header->prev = temp;
	//ret = func(value, &(temp->data));
	header->prev->data = value;
	temp=NULL;
	return ret;
}



/*
 * function: ergodic link data
 */
int commlink::ergodicLink(int (*func)(void *, void *), void *result)
{
	int		i = 0;
	LinkNode	*position;

	position = header->next;
	for(i=0;;i++)
	{
		if(position != header)
		{
			func(position->data, result);
			position = position->next;
		}
		else
		{
			break;
		}
	}
	return 0;
}



/*
 * function: sort link
 * input: linkhead, compare_function
 * output: linksorted
 */
int commlink::sortLink(int (*linkDataCompare)(void *, void *))
{
	if(NULL == header)
		return -1;
	qsort(header->next, header->prev, linkDataCompare);

	return 0;
}



/*
 * function free whole link
 */
//int commlink::freeLink(LinkNode *header, int (*func)(void *))
int commlink::freeLink(void)
{
	LinkNode	*position = NULL;

	if (NULL == header)
		return 0;
	position = header->prev;
	while (position != header)
	{
			position->prev->next = header;
			header->prev = position->prev;
			free(position->data);
			free(position);
			position = header->prev;
	}
	free(position);
	return 0;
}



/*
 * function: exchange two node
 */
int commlink::exchangeNode(LinkNode *px, LinkNode *py)
{
	LinkNode temp;

	temp.data = px->data;
	px->data = py->data;
	py->data = temp.data;

	return 0;
}



/*
 * sort link with quik sort method
 * input: firtnode,secondnode,compare_function
 * output: sorted link
 */
int commlink::qsort(LinkNode *node_head, LinkNode *node_tail, int (*linkDataCompare)(void *, void *))
{
	int		iRet = 0;
	LinkNode	*key = NULL;
	LinkNode	*node_front = NULL;
	LinkNode	*node_behind = NULL;

	if(node_head == node_tail)
	{
		return 0;
	}

	node_front = node_head;
	node_behind = node_tail;
	key = node_head;

	while(node_front != node_behind)
	{
		//start from behind to front
		while(node_front != node_behind)
		{
			if((iRet = linkDataCompare(node_behind->data, key->data)) < 0)
				break;
			else
				node_behind = node_behind->prev;
		}

		//start from front to behind
		while(node_front != node_behind)
		{
			if((iRet = linkDataCompare(node_front->data, key->data)) >= 0)
				break;
			else
				node_front = node_front->next;
		}

		//exchange the two nodes
		if(node_front != node_behind)
			exchangeNode(node_front, node_behind);
		else
			break;
	}

	exchangeNode(key, node_front);

	key = node_front;
	if(key != node_head)
		qsort(node_head, key->prev, linkDataCompare);
	qsort(key->next, node_tail, linkDataCompare);

	return 0;
}


LinkNode *commlink::set_header(void)
{
	cur_position = header;
	return cur_position;
}

LinkNode *commlink::set_begin(void)
{
	cur_position = header->next;
	return cur_position;
}

LinkNode *commlink::set_end(void)
{
	cur_position = header->prev;
	return cur_position;
}

LinkNode *commlink::get_header(void)
{
	return header;
}

LinkNode *commlink::get_begin(void)
{
	return header->next;
}

LinkNode *commlink::get_end(void)
{
	return header->prev;
}

LinkNode *commlink::next(void)
{
	cur_position = cur_position->next;
	return cur_position;
}

LinkNode *commlink::prev(void)
{
	cur_position = cur_position->prev;
	return cur_position;
}

LinkNode *commlink::current(void)
{
	return cur_position;
}

/*
 * function: exchange two node
 */
int commlink::moveToTail(LinkNode *node)
{
	node->prev->next = node->next;
	node->next->prev = node->prev;
	node->prev = header->prev;
	node->next = header;
	header->prev->next = node;
	header->prev = node;

	return 0;
}

/*
 * function: delete node from the Link
 */
int commlink::deleteLinkNode(LinkNode *node)
{
    if(node != header)
    {
        node->prev->next = node->next;
        node->next->prev = node->prev;
        free(node->data);
        free(node);
    }

    return 0;
}
