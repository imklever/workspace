#ifndef _COMMLINK_H_
#define _COMMLINK_H_

#include "linkData.h"

using namespace std;

typedef struct linkNode
{
	struct linkNode *prev;
	struct linkNode *next;

	struct linkNode *parent;
	struct linkNode *child;
	struct linkNode *childTail;
	struct linkNode *childLen;

	void            *data;
}LinkNode;

class commlink
{
	private:
		LinkNode *header;
		LinkNode *cur_position;
	public:
		LinkNode *t_position;
	private:
		int exchangeNode(LinkNode *px, LinkNode *py);
		int qsort(LinkNode *node_head, LinkNode *node_tail, int (*linkDataCompare)(void *, void *));

		int createLinkHead(void);
		int freeLink(void);
	public:
		commlink(void);
		~commlink(void);
	
		//int addLinkTail(LinkNode *header, void *value, int (*func)(void *value, void **data));
		//int freeLink(LinkNode *header, int (*func)(void *data));
		
		//int addLinkhead(void *value);
		int addLinkTail(void *value);
        //int addLinkchildhead(linkNode *parent, void *value);
        int addLinkchildTail(linkNode *parent, void *value);

        int deleteLinkNode(LinkNode *node);

		int moveToTail(LinkNode *node);

		int ergodicLink(int (*func)(void *, void *), void *);

		int sortLink(int (*linkDataCompare)(void *, void *));

		LinkNode *get_header(void);
		LinkNode *get_begin(void);
		LinkNode *get_end(void);
		LinkNode *next(void);
		LinkNode *prev(void);
		LinkNode *current(void);
		LinkNode *set_header(void);
		LinkNode *set_begin(void);
		LinkNode *set_end(void);
};

#endif
