Tested on Vivado 2021.1.1

Run from TCL command line from project root using command "source cache_controller_project.tcl" to build project.

***

## Abstract ##

The objective of this project is to understand the functionality of a cache controller by studying how the processor, Static Random-Access Memory (SRAM) and Synchronous Dynamic Random-Access Memory (SDRAM) interact. The project showcases a system with 256byte SRAM cache, 64kByte main system memory and a simulated processor core to demonstrate how a cached processor reads and writes data between itself and system memory.

***

## Introduction ##

With the needs for faster and cheaper computers, system designers must balance the need for performance and cost. The concept of cache enables processors to achieve a better performance to cost ratio by keeping frequently used data in expensive high-speed memory and keeping infrequently used data in cheaper low speed memory. If implemented correctly, the advantages of high-speed memory can be maximized, while minimizing the disadvantages such as high cost by offsetting the memory requirements to cheaper SDRAM.

***

## Block Diagram ##

<img width="1317" alt="Screen Shot 2022-04-12 at 2 28 49 PM" src="https://user-images.githubusercontent.com/76194492/163029436-4521bdb5-22b4-4157-97e9-de7dbdebde70.png">
Diagram 1: Cache Controller Block Diagram

***

## State Machine ## 

<img width="1593" alt="Screen Shot 2022-04-11 at 1 44 57 PM" src="https://user-images.githubusercontent.com/76194492/162798781-36a5a91f-4fab-42e5-9b18-6c6fab87b4b2.png">
Diagram 2: Cache Controller State Diagram

***

## Simulation Results ##

Note clock period -> 100ns.

Instruction 1:  Write command with a “SRAM memory MISS” and “SDRAM to SRAM memory write” required. No “SRAM to SDRAM writeback” required. 

Since this is the first instruction being sent to the cache controller by the CPU, the Tag Registration Block and similarly the SRAM are empty (see Table 1A and Table 1F). The Tag Registration Block stores the “Tag” portion of the address from bit 15 down to bit 8. This part of the address is required to reference the main memory, however, for SRAM operation, we require only reference based off bits 7 down to 5 of the address known as the index. Consequently, the SRAM has 8 memory slots referenced by the index, where each slot corresponds to 32 bytes addressed by the remaining bits of the address from bits 4 down to 0 known as the “offset”. This gives the SRAM a total size of 255 bytes and similarly gives 255 memory spots of 8-bit data. Furthermore, it should be noted that since the CPU is addressing with 16 bits and processing 8-bit data the main memory has 65535 index location with a total size of 65535 bytes. Since this first command is a write command, data is provided by the CPU to update the main memory. The CPU does not directly interact with main SDRAM memory, but through high-speed intermediary SRAM memory. Consequently, the SRAM memory must first be updated with the appropriate data from the SDRAM before the CPU can modify any information. Data at the address provided by the CPU is fetched from the SDRAM (see Table 1C) and brought into the SRAM at the appropriate index location (see Table 1F) where the Tag and the validity of the SRAM cache data (sets valid bit flag HIGH) is recorded in the Tag registration table (see Table 3). An entry is determined to be valid after the entire 32-byte block is transferred from SDRAM to SRAM (see Figure 1D @ 0.0106us). When the current task segment ends or is interrupted all valid bits for all index position in the SRAM become invalid. This mechanism prevents erroneous data from being sent to the CPU from previously loaded data in the cache that is irrelevant for the current task. However, it should be noted that invalidation of cached data is beyond the scope of the project and this demonstration. After the memory block has been updated post SDRAM to SRAM write, data provided by the CPU is written to the specified address in the SRAM. This modifies the data associated with the current address and consequently sets the dirty-bit flag HIGH (see Table 1D Figure 1D @ 0.0107us). This mechanism helps ensure memory coherency by indicating modified data that cannot be overwritten in the SRAM. As a result, all entries with a dirty-bit flag set HIGH must be written back to SDRAM before being overwritten in subsequent instructions. The execution of this first instruction provided by the CPU has been completed by the cache controller and the data provided has been successfully written to memory. 

<img width="1568" alt="Screen Shot 2022-04-10 at 8 58 10 PM" src="https://user-images.githubusercontent.com/76194492/162648700-56ec9630-1fda-42b0-bd46-c94daea32e06.png">

Figure 1A: SRAM miss with SDRAM to SRAM write operation (CPU write operation) PART1 

<img width="1553" alt="Screen Shot 2022-04-10 at 9 03 48 PM" src="https://user-images.githubusercontent.com/76194492/162648887-5a66d2e3-ba0b-4f06-b598-0fa57a55628c.png">

Figure 1B: SRAM miss with SDRAM to SRAM write operation (CPU write operation) PART2

<img width="1553" alt="Screen Shot 2022-04-10 at 9 05 33 PM" src="https://user-images.githubusercontent.com/76194492/162648961-03f3c1eb-e817-48b7-8941-d439024def6f.png">

Figure 1C: SRAM miss with SDRAM to SRAM write operation (CPU write operation) PART3

<img width="1553" alt="Screen Shot 2022-04-10 at 9 06 50 PM" src="https://user-images.githubusercontent.com/76194492/162649033-252a1227-ae03-4669-ac37-ffeecb24a256.png">

Figure 1D: SRAM miss with SDRAM to SRAM write operation (CPU write operation) PART4

<img width="1560" alt="Screen Shot 2022-04-10 at 9 08 06 PM" src="https://user-images.githubusercontent.com/76194492/162649099-bdddc755-8cb6-4db2-841f-ecbdf011928d.png">

Table 1A: Pre SDRAM to SRAM write procedure during first instruction. (SRAM empty)

<img width="1560" alt="Screen Shot 2022-04-10 at 9 09 13 PM" src="https://user-images.githubusercontent.com/76194492/162649157-df3e3575-53c0-4a9b-be59-0165a7ce79cb.png">

Table 1B: Post SDRAM to SRAM write procedure during first instruction. (Before write operation)

<img width="1565" alt="Screen Shot 2022-04-10 at 9 10 14 PM" src="https://user-images.githubusercontent.com/76194492/162649203-f9d9af04-9799-4c0f-8232-2ffcdb4e9628.png">

Table 1C: SDRAM contents at address 0001000100000000/4352 -> 0001000100011111/4383. (BIN/DEC) 

<img width="1556" alt="Screen Shot 2022-04-10 at 9 11 02 PM" src="https://user-images.githubusercontent.com/76194492/162649242-c432bc39-1501-43a3-858b-f603871b4749.png">

Table 1D: Post first instruction SRAM memory content.  

<img width="1556" alt="Screen Shot 2022-04-10 at 9 11 48 PM" src="https://user-images.githubusercontent.com/76194492/162649294-d3689366-8704-48a6-8843-c9e6e4d314f0.png">

Table 1E: Pre first instruction Tag Registration block contents. 

<img width="1556" alt="Screen Shot 2022-04-10 at 9 13 08 PM" src="https://user-images.githubusercontent.com/76194492/162649373-96fff546-8de2-4575-a333-03a201298b4c.png">

Table 1F: Post first instruction Tag Registration block contents.

***

Instruction 2:  Write command with a “SRAM memory HIT”. No “SDRAM to SRAM write” required. No “SRAM to SDRAM writeback” required. 

Referencing Figure 2, instruction two begins at 0.0014us, where the CPU sends a new address “0001000100000010” with data “10111011” as a write instruction. Since the tag and index portion of the second instruction address match the tag and index value of the first instruction currently present in the Tag Registration Table, the cache controller computes a data “HIT” (see Table 1D and 1F). This signifies that the 32-byte block of data associated with the current address already exist in the SRAM. As a result, the cache controller doesn’t need to update the SRAM memory contents from main SDRAM memory or copy back modified SRAM data to the SDRAM before overwriting the current index location. Consequently, the cache controller simply takes the data provided by the CPU and updates the SRAM contents at the appropriate memory offset (see Table 2). Furthermore, the dirty bit associated with the current index is set HIGH, to indicate modified data.  Execution of second instruction is complete with the data provided by the CPU being written to memory. 

<img width="1543" alt="Screen Shot 2022-04-10 at 9 20 40 PM" src="https://user-images.githubusercontent.com/76194492/162649863-93133584-1d70-4a97-abd6-12ebc2a768e4.png">

Figure 2: SRAM HIT, with CPU write operation. 

<img width="1559" alt="Screen Shot 2022-04-10 at 9 21 31 PM" src="https://user-images.githubusercontent.com/76194492/162649936-cf3e2a20-d996-4425-bdaf-9fe966188eaa.png">

Table 2: Post second instruction SRAM memory contents. 

***

Instruction 3:  Read command with a “SRAM memory HIT”. No “SDRAM to SRAM write” required. No “SRAM to SDRAM writeback” required. 

Referencing Figure 3, instruction three begins at 0.0124us, where the CPU sends a new address “0001000100000000” as a read instruction. Like instruction two, the tag and index portion of the third instruction address match a valid tag and index value already present in the Tag Registration Table, causing the cache controller to compute a data “HIT”. The cache controller outputs the data associated with the provided address to the CPU completing execution of the third instruction. This can be observed in Table 2 and Figure 3 at 0.0131us, by data contained in the SRAM at the first index location of “10101010” being output by cache controller through the “to_cpu_output[7:0]” output to the CPU. 

<img width="1549" alt="Screen Shot 2022-04-10 at 9 23 44 PM" src="https://user-images.githubusercontent.com/76194492/162650073-05f05562-c14b-45ac-afe9-b8f21daf5a8f.png">

Figure 3: SRAM HIT, CPU read operation. 

***

Instruction 4:  Read command with a “SRAM memory HIT”. No “SDRAM to SRAM write” required. No “SRAM to SDRAM writeback” required. 

Referencing Figure 4, instruction four begins at 0.0137us, where the CPU sends a new address “0001000100000010” as a read instruction. This is the exact same instruction type as instruction three, but at a different memory offset location in the SRAM. Consequently, the tag and index portion of the fourth instruction address match a valid tag and index value already present in the Tag Registration Table causing the cache controller to compute a data “HIT”. The cache controller outputs the data associated with the provided address to the CPU completing the execution of the fourth instruction. This can be observed in Table 2 and Figure 4 at 0.0144us, with the data contained in the SRAM at the third index location of “10111011” being output by cache controller through the “to_cpu_output[7:0]” output to the CPU. 

<img width="1549" alt="Screen Shot 2022-04-10 at 9 24 49 PM" src="https://user-images.githubusercontent.com/76194492/162650149-0ae42569-8bdd-4b52-9212-861146dc559a.png">

Figure 4: SRAM HIT, with CPU read operation.

***

Instruction 5:  Read command with a “SRAM memory MISS”. “SDRAM to SRAM write” required. No “SRAM to SDRAM writeback” required. 

Referencing Figure 5A, instruction 5 begins at 0.0150us with the CPU providing a read instruction at address “0011001101000110”. Neither the tag nor index portion of the address matches previously stored address data in the Tag Registration Table. Since the index associated with the address is empty in SRAM, determined by the valid bit being set LOW, the cache controller updates the contents of SRAM memory by performing a SDRAM to SRAM write procedure (see Figure 5A to 5E). Comparing Table 2 against Table 5A, it can be observed that after instruction five completes execution, the contents from the SDRAM memory have been copied into SRAM memory at the appropriate location. Furthermore, observable in Figure 5E at 0.0250us, the valid bit and tag parameter in the Tag Registration Table associated with the current index are updated after completion of the SDRAM to SRAM write procedure (see Table 5B).  Finally, the cache controller completes the read instruction by sending data referenced by the address to the CPU and terminating at 0.0261us. 

<img width="1561" alt="Screen Shot 2022-04-10 at 9 26 23 PM" src="https://user-images.githubusercontent.com/76194492/162650311-70b0ad16-14b4-431c-a9a9-c2a3d9461e56.png">

Figure 5A: SRAM miss with SDRAM to SRAM write operation (CPU read operation) PART1

<img width="1540" alt="Screen Shot 2022-04-10 at 9 30 28 PM" src="https://user-images.githubusercontent.com/76194492/162650553-3f6a56a6-8c94-427c-94e9-f3c6f7071bb1.png">

Figure 5B: SRAM miss with SDRAM to SRAM write operation (CPU read operation) PART2

<img width="1540" alt="Screen Shot 2022-04-10 at 9 32 02 PM" src="https://user-images.githubusercontent.com/76194492/162650631-3141c32f-43ae-4bc2-9ca9-c69cd0f3a5a4.png">

Figure 5C: SRAM miss with SDRAM to SRAM write operation (CPU read operation) PART3

<img width="1540" alt="Screen Shot 2022-04-10 at 9 33 17 PM" src="https://user-images.githubusercontent.com/76194492/162650688-099958ea-53f6-4354-8e31-bb83be53a35f.png">

Figure 5D: SRAM miss with SDRAM to SRAM write operation (CPU read operation) PART4

<img width="1540" alt="Screen Shot 2022-04-10 at 9 34 04 PM" src="https://user-images.githubusercontent.com/76194492/162650730-b379ebb5-96aa-4b2a-9453-b39fdec21e6f.png">

Figure 5E: SRAM miss with SDRAM to SRAM write operation (CPU read operation) PART5

<img width="1556" alt="Screen Shot 2022-04-10 at 9 35 01 PM" src="https://user-images.githubusercontent.com/76194492/162650787-3a90723d-63c4-4785-9e0d-6c171f82e884.png">

Table 5A: Post fifth instruction SDRAM to SRAM write procedure.

<img width="1528" alt="Screen Shot 2022-04-10 at 9 36 10 PM" src="https://user-images.githubusercontent.com/76194492/162650906-b93a9970-9b14-4664-9f3f-07cf6fec51ef.png">

Table 5B: Post fifth instruction Tag Registration block contents.

***

Instruction 6:  Read command with a “SRAM memory MISS”. “SDRAM to SRAM write” required. No “SRAM to SDRAM writeback” required. 

Referencing Figure 6A, instruction six starts at 0.0261us by the CPU sending address “0100010001000100” as a read command. For the current index location, the valid bit is set HIGH, and the dirty bit is set LOW. Furthermore, the tag portion of the address data stored in the Tag Registration Table does not match. An index with a valid bit set HIGH, without a matching tag, indicates old data associated with another address already existing in the SRAM at the current memory location. Consequently, the cache controller must check the dirty bit value to determine if modified data exist at the current index location. Since the dirty bit is set LOW, indicating no data modifications throughout the current 32-byte memory block on SRAM, a simple SDRAM to SRAM write procedure can overwrite and update the contents of the SRAM with data associated with the current address. Although not applicable for this situation, if the dirty bit was set HIGH for the current index, the cache controller would need to first write SRAM contents back to main memory before any new information could be updated on the SRAM to maintain memory coherency. But as can be observed in Figure 6A, the dirty bit is set LOW, indicating that no data modification has been made in prior instructions and old data can be safely overwritten with new data associated with the current address. Referencing Figure 6A-6E, to execution instruction six, the cache controller first overwrites the old data conflicting with the current index where after completion the current tag is updated in the Tag Registration table (see Table 6A and Table 6B). Since this is a read operation, the content at the specified address is then fetched from SRAM and returned to the CPU, where execution of instruction six is complete at 0.0372us. 

<img width="1556" alt="Screen Shot 2022-04-10 at 9 43 58 PM" src="https://user-images.githubusercontent.com/76194492/162651444-cfd12796-c6dd-43e5-8f82-f7529c19fdfe.png">

Figure 6A: SRAM miss with SDRAM to SRAM write operation (CPU read operation) PART 1

<img width="1556" alt="Screen Shot 2022-04-10 at 9 44 58 PM" src="https://user-images.githubusercontent.com/76194492/162651514-ffa6004a-1620-464c-a1cc-c3feb4516b2b.png">

Figure 6B: SRAM miss with SDRAM to SRAM write operation (CPU read operation) PART 2

<img width="1556" alt="Screen Shot 2022-04-10 at 9 45 48 PM" src="https://user-images.githubusercontent.com/76194492/162651560-c2cfd808-4ca3-421c-a1bd-506934934f95.png">

Figure 6C: SRAM miss with SDRAM to SRAM write operation (CPU read operation) PART 3

<img width="1556" alt="Screen Shot 2022-04-10 at 9 49 26 PM" src="https://user-images.githubusercontent.com/76194492/162651827-1c2685fd-6529-49ab-98fc-d2e62ca6d0ef.png">

Figure 6D: SRAM miss with SDRAM to SRAM write operation (CPU read operation) PART 4

<img width="1556" alt="Screen Shot 2022-04-10 at 9 50 41 PM" src="https://user-images.githubusercontent.com/76194492/162651942-8f01ecfd-1cb1-4b3d-9c93-3a062bd75710.png">

Figure 6E: SRAM miss with SDRAM to SRAM write operation (CPU read operation) PART 5

<img width="1547" alt="Screen Shot 2022-04-10 at 9 52 13 PM" src="https://user-images.githubusercontent.com/76194492/162652047-c980ec8c-ee4a-4cdf-810c-03fbd655995c.png">

Table 6A: Post sixth instruction SRAM memory contents. 

<img width="1550" alt="Screen Shot 2022-04-10 at 9 53 33 PM" src="https://user-images.githubusercontent.com/76194492/162652167-22be45c3-ff8b-4a3c-b994-b75ec1b4085a.png">

Table 6B: Post sixth instruction Tag Registration block contents.

***


Instruction 7:  Write command with a “SRAM memory MISS”. “SDRAM to SRAM write” required.  “SRAM to SDRAM writeback” required. 

Referencing Figure 7A, instruction seven starts at 0.0372us by the CPU sending address “0101010100000100” as a write command. At current index location, the valid bit is set HIGH, the dirty bit is set HIGH, and the current tag does not match the tag present in the Tag Registration Table. The valid bit set HIGH with the tag values differing signifies that old data exist in the SRAM at the current index location not associated with the current address. Additionally, the dirty bit being set HIGH, indicates that data within the 32-byte memory block has been modified. Consequently, before the SRAM can be updated with data associated with the current address, the cache controller must write back the memory block at the conflicting index from SRAM to SDRAM. Referencing Figure 7A to 7D, the cache controller writes old SRAM data at the conflicting index location back to SDRAM corresponding to the old address. Once the SRAM to SDRAM writeback procedure is complete at 0.0473us, the cache controller sets the dirty bit associated with the index LOW and updates the SRAM with data associated with the current address by performing and SDRAM to SRAM write procedure (see Figure 7D to 7H). After the SDRAM to SRAM write procedure is complete at 0.0573us, the cache controller updates the Tag Registration Table with the current tag and writes data provided by the CPU at the appropriate index in the SRAM (see Table 7A and Table 7B). Furthermore, since data has been modified in SRAM through the write operation, the cache controller sets the dirty it associated with the current index HIGH. Instruction seven completes execution at 0.0580us. 

<img width="1557" alt="Screen Shot 2022-04-10 at 9 55 50 PM" src="https://user-images.githubusercontent.com/76194492/162652389-a30a5a04-b6e6-40bd-ac6a-59d9ef916cf9.png">

Figure 7A: SRAM miss, SRAM to SDRAM write operation (CPU write operation) PART 1

<img width="1557" alt="Screen Shot 2022-04-10 at 9 57 13 PM" src="https://user-images.githubusercontent.com/76194492/162652465-54f75e99-ec0a-4101-bf29-b5c33f553213.png">

Figure 7B: SRAM miss, SRAM to SDRAM write operation (CPU write operation) PART 2

<img width="1557" alt="Screen Shot 2022-04-10 at 9 59 51 PM" src="https://user-images.githubusercontent.com/76194492/162652688-20972477-e3ef-44c3-be43-830e46c40bb2.png">

Figure 7C: SRAM miss, SRAM to SDRAM write operation (CPU write operation) PART 3

<img width="1557" alt="Screen Shot 2022-04-10 at 10 00 42 PM" src="https://user-images.githubusercontent.com/76194492/162652765-b3c3b2cc-28a0-4722-8620-4f81c18c9239.png">

Figure 7D: SRAM miss, SRAM to SDRAM write operation (CPU write operation) PART 4

<img width="1557" alt="Screen Shot 2022-04-10 at 10 02 04 PM" src="https://user-images.githubusercontent.com/76194492/162652859-b91768ba-7bdf-45b5-b938-e7a2967559c0.png">

Figure 7E: SRAM miss, SDRAM to SRAM write operation (CPU write operation) PART 1

<img width="1557" alt="Screen Shot 2022-04-10 at 10 02 54 PM" src="https://user-images.githubusercontent.com/76194492/162652914-501d0aa7-947a-4160-92db-6a6ac7210998.png">

Figure 7F: SRAM miss, SDRAM to SRAM write operation (CPU write operation) PART 2

<img width="1557" alt="Screen Shot 2022-04-10 at 10 04 52 PM" src="https://user-images.githubusercontent.com/76194492/162653108-8efebbc2-6506-4705-bdc5-dca8a2032c93.png">

Figure 7G: SRAM miss, SDRAM to SRAM write operation (CPU write operation) PART 3

<img width="1557" alt="Screen Shot 2022-04-10 at 10 05 56 PM" src="https://user-images.githubusercontent.com/76194492/162653192-1d1295eb-af7f-4476-996d-5aa7759c7b8c.png">

Figure 7H: SRAM miss, SDRAM to SRAM write operation (CPU write operation) PART 4

<img width="1557" alt="Screen Shot 2022-04-10 at 10 06 39 PM" src="https://user-images.githubusercontent.com/76194492/162653254-1c1d530e-b1ca-4a40-94ee-2ceddc4e99cf.png">

Figure 7I: SRAM miss, SDRAM to SRAM write operation (CPU write operation) PART 5

<img width="1557" alt="Screen Shot 2022-04-10 at 10 10 01 PM" src="https://user-images.githubusercontent.com/76194492/162653494-8a1faca7-a3ed-4841-9eb4-0eee2b48c4b3.png">

Table 7A: Post seventh instruction SRAM memory contents.

<img width="1552" alt="Screen Shot 2022-04-10 at 10 10 47 PM" src="https://user-images.githubusercontent.com/76194492/162653567-43c186a1-129e-4841-a9ce-df7ca5c6b9b6.png">

Table 7B: Post seventh instruction Tag Registration block contents.

***

Instruction 8:  Read command with a “SRAM memory MISS”. “SDRAM to SRAM write” required.  “SRAM to SDRAM writeback” required. 

Referencing Figure 8A, instruction eight starts at 0.0580us by the CPU sending address “0110011000000110” as a read command. At current index location, the valid bit is set HIGH, the dirty bit is set HIGH, and the current tag does not match the tag present in the Tag Registration Table. Consequently, old, modified data is associated with the current index and must be written back to main memory before new data associated with the current address can be updated to SRAM. Observing Figure 8A to 8D, the cache controller writes modified data in the SRAM back to SDRAM at the origin address. After the SRAM to SDRAM write procedure is completion at 0.0682us, the cache controller sets the dirty bit LOW, and proceeds to update the SRAM with data associated with the current address by performing and SDRAM to SRAM write procedure. After the SDRAM to SRAM write operation is complete and the Tag Registration Table has been updated with the current data, the cache controller forwards data associated with the address to the CPU (see Table 8A and Table 8B). Instruction eight completes execution and terminates at 0.0791us. 


<img width="1552" alt="Screen Shot 2022-04-10 at 10 13 30 PM" src="https://user-images.githubusercontent.com/76194492/162653836-6d8248f4-9dbe-44c5-bbc8-0f360c68ce87.png">

Figure 8A: SRAM miss, SRAM to SDRAM write operation (CPU read operation) PART 1

<img width="1552" alt="Screen Shot 2022-04-10 at 10 14 36 PM" src="https://user-images.githubusercontent.com/76194492/162653884-ef46347b-f3e2-475f-b9bc-e0cae566302c.png">

Figure 8B: SRAM miss, SRAM to SDRAM write operation (CPU read operation) PART 2

<img width="1552" alt="Screen Shot 2022-04-10 at 10 15 29 PM" src="https://user-images.githubusercontent.com/76194492/162653951-c03ae2ee-86cb-406e-80b1-57e5e0757a09.png">

Figure 8C: SRAM miss, SRAM to SDRAM write operation (CPU read operation) PART 3

<img width="1552" alt="Screen Shot 2022-04-10 at 10 16 18 PM" src="https://user-images.githubusercontent.com/76194492/162654011-7382a4b9-01bc-4129-8b0d-80a5cb6c335d.png">

Figure 8D: SRAM miss, SRAM to SDRAM write operation (CPU read operation) PART 4

<img width="1552" alt="Screen Shot 2022-04-10 at 10 17 07 PM" src="https://user-images.githubusercontent.com/76194492/162654085-910def67-ccfc-4215-aadc-4c6c4a8afd7b.png">

Figure 8E: SRAM miss, SDRAM to SRAM write operation (CPU read operation) PART 1
 
<img width="1552" alt="Screen Shot 2022-04-10 at 10 19 18 PM" src="https://user-images.githubusercontent.com/76194492/162654234-73edbc62-dee0-443d-bebe-406a00d2fc9c.png">

Figure 8F: SRAM miss, SDRAM to SRAM write operation (CPU read operation) PART 2

<img width="1552" alt="Screen Shot 2022-04-10 at 10 20 27 PM" src="https://user-images.githubusercontent.com/76194492/162654329-a744c7a6-5754-4ae8-be92-d8aa8efdb3fb.png">

Figure 8G: SRAM miss, SDRAM to SRAM write operation (CPU read operation) PART 3

<img width="1552" alt="Screen Shot 2022-04-10 at 10 21 55 PM" src="https://user-images.githubusercontent.com/76194492/162654431-843bcaa8-2560-4eb7-9404-5de16cc40454.png">

Figure 8H: SRAM miss, SDRAM to SRAM write operation (CPU read operation) PART 4

<img width="1552" alt="Screen Shot 2022-04-10 at 10 23 13 PM" src="https://user-images.githubusercontent.com/76194492/162654506-56af328e-9bc8-4efb-bab2-655ad8e9a53b.png">

Figure 8I: SRAM miss, SDRAM to SRAM write operation (CPU read operation) PART 5

<img width="1559" alt="Screen Shot 2022-04-10 at 10 24 14 PM" src="https://user-images.githubusercontent.com/76194492/162654587-29805234-72f8-4130-a689-6eaebf8554b7.png">

Table 8A: Post eighth instruction SRAM memory contents

<img width="1534" alt="Screen Shot 2022-04-10 at 10 24 59 PM" src="https://user-images.githubusercontent.com/76194492/162654664-5c678426-786f-4e5c-bba3-747c147e7124.png">

Table 8B: Post eighth instruction Tag Registration block contents

***

## Performance Summary ##

<img width="1730" alt="Screen Shot 2022-04-12 at 3 10 40 PM" src="https://user-images.githubusercontent.com/76194492/163036105-7883f602-d858-4839-a2ea-a99fec97b412.png">
Table 9: Cache Controller Performance Summary 

