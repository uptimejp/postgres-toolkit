/*
 * verifychecksum.c
 *
 * Copyright(c) 2015 Uptime Technologies, LLC.
 */
#include <stdio.h>
#include <unistd.h>

#include "c.h"
#include "pg_config.h"
#include "storage/checksum.h"
#include "storage/checksum_impl.h"

int verify_page(const char *page, BlockNumber blkno, const char *filepath);
int verify_segmentfile(const char *filepath);


int verbose = 0;

int verify_page(const char *page, BlockNumber blkno, const char *filepath);
int verify_segmentfile(const char *filepath, const int segno);


int
verify_page(const char *page, BlockNumber blkno, const char *filepath)
{
  PageHeader	phdr = (PageHeader) page;
  uint16 checksum;

  checksum = pg_checksum_page((char *)page, blkno);

  /*
   * In 9.2 or lower, pd_checksum is 1 since data checksums are not supported.
   */
  if (blkno == 0 && phdr->pd_checksum == 1)
    {
      printf("%s: Data checksums are not supported. (9.2 or lower)\n",
	     filepath);
      exit(2);
    }

  /*
   * pd_checksum is 0 if data checksums are disabled.
   */
  if (blkno == 0 && phdr->pd_checksum == 0)
    {
      printf("%s: Data checksums are disabled.\n",
	     filepath);
      exit(2);
    }

  if (phdr->pd_checksum != checksum)
    {
      printf("%s: blkno %d, page header %x, calculated %x\n",
	     filepath, blkno, phdr->pd_checksum, checksum);
      return FALSE;
    }

  return TRUE;
}

int
verify_segmentfile(const char *filepath, const int segno)
{
  int fd;
  char page[BLCKSZ];
  BlockNumber blkno = 0;
  BlockNumber corrupted = 0;
  char* filename;
  int segno = 0;

  fd = open(filepath, O_RDONLY);
  if (fd <= 0)
    {
      fprintf(stderr, "%s: %s\n", strerror(errno), filepath);
      exit(2);
    }


  filename = strdup(filepath);
  if (strstr(basename(filename), "."))
    {
      segno = atoi(strstr(basename(filename), ".")+1);
    }

  while (read(fd, page, BLCKSZ) == BLCKSZ)
    {
      if (!verify_page(page, segno * RELSEG_SIZE + blkno, filepath))
	{
	  corrupted++;
	}
      blkno++;
    }

  close(fd);

  if (corrupted > 0)
    {
      printf("%d blocks corrupted in %s.\n", corrupted, filepath);
      return FALSE;
    }

  if (verbose)
    printf("Verified %d blocks in %s.\n", blkno, filepath);

  return TRUE;
}

int
main(int argc, char *argv[])
{
  //  printf("BLCKSZ: %d\n", BLCKSZ);
  char *file = NULL;
  int segno = 0;
  int i;

  for (i=1 ; i<argc ; i++)
    {
      if (strcmp(argv[i], "-v") == 0)
	{
	  verbose = 1;
	  continue;
	}

      if (file == NULL)
	file = argv[i];
      else
	segno = atoi(argv[i]);
    }

  if (file == NULL)
    {
      printf("Usage: verifychecksum [-v] [segment file] [segment number]\n");
      return 0;
    }

  if (!verify_segmentfile(file, segno))
    {
      /* corrupted blocks found. */
      return 1;
    }

  return 0;
}
