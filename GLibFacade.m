/*
 *	GLibFacade.m
 *	MultiMarkdown
 *	
 *	Created by Daniel Jalkut on 7/26/11.
 *	Copyright 2011 __MyCompanyName__. All rights reserved.
 */

#include "GLibFacade.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdarg.h>

/* GString */

#define kStringBufferStartingSize 1024
#define kStringBufferGrowthMultiplier 2

GString* g_string_new(char *startingString)
{
	GString* newString = malloc(sizeof(GString));

	if (startingString == NULL) startingString = "";

	size_t startingBufferSize = kStringBufferStartingSize;
	size_t startingStringSize = strlen(startingString);
	while (startingBufferSize < (startingStringSize + 1))
	{
		startingBufferSize *= kStringBufferGrowthMultiplier;
	}
	
	newString->str = malloc(startingBufferSize);
	newString->currentStringBufferSize = startingBufferSize;
	strncpy(newString->str, startingString, startingStringSize);
	newString->str[startingStringSize] = '\0';
	newString->currentStringLength = startingStringSize;
	
	return newString;
}

char* g_string_free(GString* ripString, bool freeCharacterData)
{	
	char* returnedString = ripString->str;
	if (freeCharacterData)
	{
		if (ripString->str != NULL)
		{
			free(ripString->str);
		}
		returnedString = NULL;
	}
	
	free(ripString);
	
	return returnedString;
}

static void ensureStringBufferCanHold(GString* baseString, size_t newStringSize)
{
	size_t newBufferSizeNeeded = newStringSize + 1;
	if (newBufferSizeNeeded > baseString->currentStringBufferSize)
	{
		size_t newBufferSize = baseString->currentStringBufferSize;	

		while (newBufferSizeNeeded > newBufferSize)
		{
			newBufferSize *= kStringBufferGrowthMultiplier;
		}
		
		baseString->str = realloc(baseString->str, newBufferSize);
		baseString->currentStringBufferSize = newBufferSize;
	}
}

void g_string_append(GString* baseString, char* appendedString)
{
	if ((appendedString != NULL) && (strlen(appendedString) > 0))
	{
		size_t appendedStringLength = strlen(appendedString);
		size_t newStringLength = baseString->currentStringLength + appendedStringLength;
		ensureStringBufferCanHold(baseString, newStringLength);

		/* We already know where the current string ends, so pass that as the starting address for strncat */
		strncat(baseString->str + baseString->currentStringLength, appendedString, appendedStringLength);
		baseString->currentStringLength = newStringLength;
	}
}

void g_string_append_c(GString* baseString, char appendedCharacter)
{	
	size_t newSizeNeeded = baseString->currentStringLength + 1;
	ensureStringBufferCanHold(baseString, newSizeNeeded);
	
	baseString->str[baseString->currentStringLength] = appendedCharacter;
	baseString->currentStringLength++;	
	baseString->str[baseString->currentStringLength] = '\0';
}

void g_string_append_printf(GString* baseString, char* format, ...)
{
	va_list args;
	va_start(args, format);
	
	char* formattedString = NULL;
	vasprintf(&formattedString, format, args);
	if (formattedString != NULL)
	{
		g_string_append(baseString, formattedString);
		free(formattedString);
	}
} 

void g_string_prepend(GString* baseString, char* prependedString)
{
	if ((prependedString != NULL) && (strlen(prependedString) > 0))
	{
		size_t prependedStringLength = strlen(prependedString);
		size_t newStringLength = baseString->currentStringLength + prependedStringLength;
		ensureStringBufferCanHold(baseString, newStringLength);

		memmove(baseString->str + prependedStringLength, baseString->str, baseString->currentStringLength);
		strncpy(baseString->str, prependedString, prependedStringLength);
		baseString->currentStringLength = newStringLength;
		baseString->str[baseString->currentStringLength] = '\0';
	}
}

/* GSList */

void g_slist_free(GSList* ripList)
{
	GSList* thisListItem = ripList;
	while (thisListItem != NULL)
	{
		GSList* nextItem = thisListItem->next;
		
		/* I guess we don't release the data? Non-retained memory management is hard... let's figure it out later. */
		free(thisListItem);
		
		thisListItem = nextItem;
	}
}

/* Currently only used for markdown_output.c endnotes printing */
GSList* g_slist_reverse(GSList* theList)
{	
	GSList* lastNodeSeen = NULL;
	
	/* Iterate the list items, tacking them on to our new reversed List as we find them */
	GSList* listWalker = theList;
	while (listWalker != NULL)
	{
		GSList* nextNode = listWalker->next;
		listWalker->next = lastNodeSeen;
		lastNodeSeen = listWalker;
		listWalker = nextNode;
	}
	
	return lastNodeSeen;
}

GSList* g_slist_prepend(GSList* targetElement, void* newElementData)
{
	GSList* newElement = malloc(sizeof(GSList));
	newElement->data = newElementData;
	newElement->next = targetElement;
	return newElement;
}

