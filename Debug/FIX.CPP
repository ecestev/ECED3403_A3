int cache_loc[2] = { NOT_SET, NOT_SET };
// If associative caching is being used we simply want to perform a linear search to see if the
// data is in the cache or not already. This will determine whether we have a 'hit' or a 'miss'.
if (CACHE_ORG == ASSOCIATIVE) {
cache_loc[0] = cache_lookup(target_address);
if (bw == WORD)
cache_loc[1] = cache_lookup(target_address + BYTE);
}
// otherwise if direct mapping is being used we determine which cache location the targer address
// maps to and see if its address is equal to the target address. If not it is a miss.
else {
	cache_loc[0] = generate_hash(target_address);
	if(cache[cache_loc[0]].address != target_address)
		cache_loc[0] = MISS;
	if(bw==WORD){
		cache_loc[1] = generate_hash(target_address + BYTE);
	if(cache[cache_loc[1]].address != target_address)
		cache_loc[1] = MISS;
	}
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