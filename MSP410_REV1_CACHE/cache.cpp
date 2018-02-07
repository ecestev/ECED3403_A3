/****************************************************************************************
*	FILE: cache.cpp
*
*	ECED 3403 - Computer Architecture
*	Stephen Sampson - B00568374
*	Assignment #3 - Cache Implementation
*	Summer 2017
*
*				Last Modified	Author
*	ORIGINAL:	July 2017		Stephen Sampson
*
*	This file contains:
*		Cache implementation for the MSP-430 ISA Emulator developped in assignment #2.
*		Both associative and direct mapping are suppoorted as well as write-back
*		and write-through methods.
****************************************************************************************/

#include "globals.h"
#include "machine.h"

using namespace std;

// ----------------------------------------------------------------------------------------------------
// 											CACHE STRUCTURE
// ----------------------------------------------------------------------------------------------------

cache_lines cache[CACHE_SIZE];

// ----------------------------------------------------------------------------------------------------
//											CACHE
// ----------------------------------------------------------------------------------------------------
void cache_access(unsigned short target_address, unsigned short *data, unsigned rw, unsigned bw) {
	if (target_address < DEVICE_LIMIT) {
		dev_mem_access(target_address, reinterpret_cast<unsigned char *>(data), rw);
		return;
	}
	int byte_pos[2] = { NOT_SET, NOT_SET };	
	// If associative caching is being used we simply want to perform a linear search to see if the
	// data is in the cache or not already. This will determine whether we have a 'hit' or a 'miss'.
	if (CACHE_ORG == ASSOCIATIVE) {
		byte_pos[0] = cache_lookup(target_address);
		if (bw == WORD)
			byte_pos[1] = cache_lookup(target_address + BYTE);
	} 
	// otherwise if direct mapping is being used we determine which cache location the targer address
	// maps to and see if its address is equal to the target address. If not it is a miss.
	else {
		byte_pos[0] = generate_hash(target_address);
		if (cache[byte_pos[0]].address != target_address) {
			byte_pos[0] = MISS;
		}
		if (bw == WORD)
			byte_pos[1] = generate_hash(target_address + BYTE);
		if (cache[byte_pos[1]].address != target_address + BYTE) {
			byte_pos[1] = MISS;
		}
	}
	// Loop helps to handle WORD read/write operations nicely (though we process one byte at a time). 
	for (int i = 0; i < 2; i++) {
		if (byte_pos[i] == NOT_SET)
			break;
		// -------------------------------------------------------------------------------------------
		//											READ 
		// -------------------------------------------------------------------------------------------
		if (rw == READ) {
			// If we have a miss, we must read the data from memory into the cache before continuing
			if (byte_pos[i] == MISS) {
				if (CACHE_ORG == ASSOCIATIVE)
					byte_pos[i] = cache_lru();
				else {
					byte_pos[i] = generate_hash(target_address + i);
				}
				// if line has been written to and requires write back to memory
				if (WRITE_METHOD == WB) {
					if (cache[byte_pos[i]].dirty == true)
						PRIM_WR((cache[byte_pos[i]].address), cache[byte_pos[i]].contents, BYTE);
				}
				// read data from primary memory into cache line
				PRIM_RD((target_address+i), cache[byte_pos[i]].contents, BYTE);
			} else {
				cache[byte_pos[i]].HITS++;
			}
			// Code common to HIT and MISS. Now the data is definitely in the cache
			// Update address and dirty bit
			cache[byte_pos[i]].address = (target_address + i);
			cache[byte_pos[i]].dirty = false;
			if (CACHE_ORG == ASSOCIATIVE) {
				// update LRU values
				for (int j = 0; j < CACHE_SIZE; j++) {
					if (cache[j].LRU > cache[byte_pos[i]].LRU)
						cache[j].LRU--;
				}
				cache[byte_pos[i]].LRU = CACHE_SIZE - 1;
			}
			// Now set value of *data to that stored in cache location
			if (i == 0) {
				*data = cache[byte_pos[i]].contents;
			} if (i == 1) {
				*data |= (cache[byte_pos[i]].contents << 8);
			}
		}
		// -------------------------------------------------------------------------------------------
		//											WRITE
		// -------------------------------------------------------------------------------------------
		else {
			if (byte_pos[i] == MISS) {
				// If we have a miss, we must write the data to the cache before continuing
				if (CACHE_ORG == ASSOCIATIVE)
					byte_pos[i] = cache_lru();
				else
					byte_pos[i] = generate_hash(target_address + i);
				// if line has been written to and requires write back to memory
				if (WRITE_METHOD == WB) {
					if (cache[byte_pos[i]].dirty == true)
						PRIM_WR((cache[byte_pos[i]].address), cache[byte_pos[i]].contents, BYTE);
				} else {
					PRIM_WR((cache[byte_pos[i]].address), cache[byte_pos[i]].contents, BYTE);
				}
				// Write data to cache line
				if (i == 0)
					cache[byte_pos[i]].contents = (*data) & 0xff;
				if (i == 1)
					cache[byte_pos[i]].contents = (*data >> 8) & 0xff;
			} else {
				cache[byte_pos[i]].HITS++;
			}
			// Code common to HIT and MISS. Now the data is definitely in the cache
			// Update address and dirty bit
			cache[byte_pos[i]].address = (target_address + i);
			cache[byte_pos[i]].dirty = true;
			if (CACHE_ORG == ASSOCIATIVE) {
				// update LRU values
				for (int j = 0; j < CACHE_SIZE; j++) {
					if (cache[j].LRU > cache[byte_pos[i]].LRU)
						cache[j].LRU--;
				}
				cache[byte_pos[i]].LRU = CACHE_SIZE - 1;
			}
		}
	}
	sys_clk++;
}


int cache_lookup(uint16_t lookup_address) {
	// perform linear search of cache
	for(int i = 0; i < CACHE_SIZE; i++) {
		if (cache[i].address == lookup_address)
			return i;
	}
	return MISS;
}

int cache_lru(void) {
	for (int i = 0; i < CACHE_SIZE; i++)
		if (cache[i].LRU == 0)
			return i;
return GENERAL_ERROR;
}

int generate_hash(uint16_t lookup_address) {
	// perform operation on address to determine cache locations
	int cache_address = lookup_address % CACHE_SIZE;
	return cache_address;
}
