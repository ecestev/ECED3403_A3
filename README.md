This assignment requires the design, implementation, and testing of cache memory to be added
to the TI 430 emulator developed in assignment 2. The objective is to demonstrate the effects
of different cache organizations and two cache replacement policies.

A single cache memory is to be placed between the CPU and the external program memory in
order to reduce memory access times. Since cache memory is usually several times faster than
primary memory, storing data and instructions in cache should reduce CPU memory-access
times, thereby increasing the speed of the machine. However, in order to experience the speedup,
the contents of the target address must be in the cache (this is referred to as a hit); if the
contents are not in the cache, the contents of the target address must be fetched and stored in
the cache (this is referred to as a miss). Various techniques can be used to increase the hit ratio;
however, due to costs, cache memory can be several orders of magnitude smaller than primary
memory.

The cache memory and the two replacement policies are to be emulated in software. Executable
programs are to be used to show the benefits and limitations of the different organizations and
replacement policies.

Regardless of the organization, a cache memory is made up of a series of lines, where each line
contains at a minimum, the address of the contents of the primary memory location and the
contents of the location. When a memory access takes place (that is, a read or a write) the cache
is inspected, if the address in question exists in the cache, a hit has occurred.

There are different ways in organizing cache memory in order to help increase the hit ratio; two
extremes are to be emulated in this assignment:

	Associative. In associative, the cache circuitry inspects each cache line for the target address
	(this is effectively a linear search). There is no relationship between the target address and its
	location in the cache memory.
	
	Direct mapping. In direct mapping, the target address is mapped directly into a cache line (this
	is a hash mapping). There is a direct relationship between the target address and its location
	in the cache memory.

The cache memory is to contain 32 lines, regardless of organization.

When a read or a write operation occurs, a 16-bit target address is supplied to the cache and the
cache is searched for the target address (see above). There are four possible combinations.

Memory reads that result in a hit require no further action; however, the remaining three
combinations require the application of replacement policies. The general policies are as follows:

 Whenever a memory access (read or write) results in a cache miss, the cache must be updated
with the new target address and the (fetched) contents of primary memory. This is to ensure
cache consistency. The location to be used depends upon the cache organization (described
above).

In an associative cache, since there is no relationship between a line and a memory address,
any line in the cache can be chosen. However, it makes little sense to select a line that is used
repeatedly as replacing it may subsequently result in a miss, requiring another fetch. A
common solution is to use a Least Recently Used (or LRU) policy that replaces, as the name
suggests, the least recently used line in the cache.
This problem does not occur in direct mapping as there is only one line that can be replaced.

 When a write occurs that results in a hit, the cache must be updated in order to ensure that a
subsequent read from that line returns the correct value. If the cache is updated but primary
memory is not, the two memories are inconsistent. There are two cache replacement policies
adopted by most caches. In the first, when a write miss occurs, the contents should be written
back to primary memory (this policy is referred to as Write Back or WB). In the second, the
value written to the cache is written to primary memory in parallel, meaning that both the
cache and primary memory are consistent (this policy is referred to as Write Through or WT).

 It is not always necessary to write a value back to primary memory; for example, cache lines
containing constants (including data that has not yet been changed) or instructions are read
but never written. In these cases, if the replacement policy indicates that the line should be
replaced there is no need to write it back to primary memory. A dirty-bit can be used to
indicate that a cache line has been written to, thereby allowing the cache algorithm to decide
whether or not the line needs to be returned to primary memory.