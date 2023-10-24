/*
 * Simple - REALLY simple memory mapping demonstration.
 *
 * Copyright (C) 2001 Alessandro Rubini and Jonathan Corbet
 * Copyright (C) 2001 O'Reilly & Associates
 *
 * The source code in this file can be freely used, adapted,
 * and redistributed in source or binary form, so long as an
 * acknowledgment appears in derived source files.  The citation
 * should list that the code comes from the book "Linux Device
 * Drivers" by Alessandro Rubini and Jonathan Corbet, published
 * by O'Reilly & Associates.   No warranty is attached;
 * we cannot take responsibility for errors or fitness for use.
 *
 * $Id: simple.c,v 1.1 2021/03/15 02:33:14 chris Exp $
 */

#include <linux/module.h>
#include <linux/moduleparam.h>
#include <linux/init.h>

#include <linux/kernel.h>   /* printk() */
#include <linux/slab.h>   /* kmalloc() */
#include <linux/fs.h>       /* everything... */
#include <linux/errno.h>    /* error codes */
#include <linux/types.h>    /* size_t */
#include <linux/mm.h>
#include <linux/uaccess.h>
#include <linux/kdev_t.h>
#include <linux/vmalloc.h>
#include <asm/page.h>
#include <linux/cdev.h>

#include <linux/device.h>
#include "simple.h"

static int simple_major = 0;
module_param(simple_major, int, 0);
MODULE_AUTHOR("Jonathan Corbet");
MODULE_LICENSE("Dual BSD/GPL");

static struct class *simple_class = NULL;

/*
 * Closing is just as simpler.
 */
static int simple_release(struct inode *inode, struct file *filp)
{
	return 0;
}



/*
 * Common VMA ops.
 */

void simple_vma_open(struct vm_area_struct *vma)
{
	printk(KERN_NOTICE "Simple VMA open, virt %lx, phys %lx\n",
			vma->vm_start, vma->vm_pgoff << PAGE_SHIFT);
}

void simple_vma_close(struct vm_area_struct *vma)
{
	printk(KERN_NOTICE "Simple VMA close.\n");
}


/*
 * The remap_pfn_range version of mmap.  This one is heavily borrowed
 * from drivers/char/mem.c.
 */

static struct vm_operations_struct simple_remap_vm_ops = {
	.open =  simple_vma_open,
	.close = simple_vma_close,
};

static int simple_remap_mmap(struct file *filp, struct vm_area_struct *vma)
{
	if (remap_pfn_range(vma, vma->vm_start, vma->vm_pgoff,
			    vma->vm_end - vma->vm_start,
			    vma->vm_page_prot))
		return -EAGAIN;

	vma->vm_ops = &simple_remap_vm_ops;
	simple_vma_open(vma);
	return 0;
}


static struct vm_operations_struct simple_nopage_vm_ops = {
	.open =   simple_vma_open,
	.close =  simple_vma_close,
};

static int simple_nopage_mmap(struct file *filp, struct vm_area_struct *vma)
{
	vma->vm_ops = &simple_nopage_vm_ops;
	simple_vma_open(vma);
	return 0;
}


/*
 * Set up the cdev structure for a device.
 */
static void simple_setup_cdev(struct cdev *dev, int minor,
		struct file_operations *fops)
{
	int err, devno = MKDEV(simple_major, minor);
    
	cdev_init(dev, fops);
	dev->owner = THIS_MODULE;
	dev->ops = fops;
	err = cdev_add (dev, devno, 1);
	/* Fail gracefully if need be */
	if (err)
		printk (KERN_NOTICE "Error %d adding simple%d", err, minor);

	if(simple_class)
		device_create(simple_class, NULL, devno, NULL, "simple%d", minor);
}

static long simple_ioctl(struct file *file, unsigned int cmd,
			unsigned long arg)
{
	int pinned;
	struct dma_io_cb * iocb_ptr;
	char *buf;
	unsigned int pf_off;
	unsigned long len;
	unsigned int pages_nr;
	struct page ** pages = NULL;
	struct page * page0;
	long int pfn;
	long int phys_addr;
	int i;
	char * vbuf = NULL;

	printk (KERN_NOTICE "cmd = %x", cmd);
       
	iocb_ptr = kzalloc(sizeof(struct dma_io_cb), GFP_KERNEL);
	printk (KERN_NOTICE "iocb_ptr = %p", iocb_ptr);

	switch (cmd) {
	case SIMPLE_IOCTL_PIN:
                (void)!copy_from_user(iocb_ptr, (struct dma_io_cb *)arg, sizeof(struct dma_io_cb));

		buf = iocb_ptr->buf;
		pf_off = offset_in_page(buf);
		len = iocb_ptr->len;
		pages_nr = (len + pf_off + PAGE_SIZE - 1) >> PAGE_SHIFT;
		pages = (struct page **) kzalloc(sizeof(struct page)*pages_nr, GFP_KERNEL);
		if (!pages) {
			printk (KERN_NOTICE "can't alloc pages");
			return -EINVAL;
		}
		printk (KERN_NOTICE "buf=%p", buf);
		printk (KERN_NOTICE "len=%lu", len);
		printk (KERN_NOTICE "pages_nr=%d", pages_nr);
		printk (KERN_NOTICE "pf_off=%d", pf_off);

		pinned = get_user_pages_fast((unsigned long)buf, pages_nr, 
				1/*write*/, pages);

	        /* No pages were pinned */
	        if (pinned != pages_nr) {
		        printk (KERN_WARNING "unable to pin down %u user pages, pinned %d.\n", 
					pages_nr, pinned);
			for (i=0; i<pinned; i++) {
				put_page(pages[i]);
			}
			kfree(pages);
			return -EINVAL;
	        }

		printk (KERN_NOTICE "pages=%p", pages);
		printk (KERN_NOTICE "pages[0]=%p", pages[0]);
		page0 = pages[0];
		printk (KERN_NOTICE "pages0=%p", page0);
		pfn = page_to_pfn(page0);
		phys_addr = pfn << PAGE_SHIFT;
		printk (KERN_NOTICE "pfn=%lx", pfn);
		printk (KERN_NOTICE "phys_addr=%lx", phys_addr);

		iocb_ptr->pages = pages;
		/* memcpy(iocb_ptr->pages, pages, sizeof(struct page)*pages_nr); */

		iocb_ptr->phys_addr = page_to_pfn(*pages) << PAGE_SHIFT;
		iocb_ptr->phys_addr = page_to_pfn(pages[0]) << PAGE_SHIFT;
		iocb_ptr->pinned = pinned;
		iocb_ptr->phys_addr = phys_addr;
		printk (KERN_NOTICE "phys_addr=%lx", iocb_ptr->phys_addr);

		/* write to buf */
		vbuf = vmap(pages,pages_nr,VM_MAP,PAGE_KERNEL);
                memset(vbuf, 3, 8);

		(void)!copy_to_user((struct dma_io_cb *)arg, iocb_ptr, sizeof(struct dma_io_cb));

		return 0;
	case SIMPLE_IOCTL_FREE:
                (void)!copy_from_user(iocb_ptr, (struct dma_io_cb *)arg, sizeof(struct dma_io_cb));

		pinned = iocb_ptr->pinned;
		pages = iocb_ptr->pages;

		printk (KERN_WARNING "free pinned %d pages, %p.\n", pinned, pages);
		vunmap(vbuf);
		for (i=0; i<pinned; i++) {
			put_page(pages[i]);
		}
		kfree(pages);
		return 0;
	default:
		break;
	}
	return 0;
}



/*
 * Our various sub-devices.
 */
/* Device 0 uses remap_pfn_range */
static struct file_operations simple_remap_ops = {
	.owner   = THIS_MODULE,
	.open    = simple_open,
	.release = simple_release,
	.mmap    = simple_remap_mmap,
	.unlocked_ioctl = simple_ioctl,
};

/* Device 1 uses nopage */
static struct file_operations simple_nopage_ops = {
	.owner   = THIS_MODULE,
	.open    = simple_open,
	.release = simple_release,
	.mmap    = simple_nopage_mmap,
};

#define MAX_SIMPLE_DEV 2


/*
 * We export two simple devices.  There's no need for us to maintain any
 * special housekeeping info, so we just deal with raw cdevs.
 */
static struct cdev SimpleDevs[MAX_SIMPLE_DEV];

/*
 * Module housekeeping.
 */
static int simple_init(void)
{
	int result;
	dev_t dev = MKDEV(simple_major, 0);

	/* Figure out our device number. */
	if (simple_major)
		result = register_chrdev_region(dev, 2, "simple");
	else {
		result = alloc_chrdev_region(&dev, 0, 2, "simple");
		simple_major = MAJOR(dev);
	}
	if (result < 0) {
		printk(KERN_WARNING "simple: unable to get major %d\n", simple_major);
		return result;
	}
	if (simple_major == 0)
		simple_major = result;

	simple_class = class_create(THIS_MODULE, "simple");
	/* Now set up two cdevs. */
	simple_setup_cdev(SimpleDevs, 0, &simple_remap_ops);
	simple_setup_cdev(SimpleDevs + 1, 1, &simple_nopage_ops);
	return 0;
}


static void simple_cleanup(void)
{
	if(simple_class)
	{
		device_destroy(simple_class, MKDEV(simple_major, 0));
		device_destroy(simple_class, MKDEV(simple_major, 1));
	}
	cdev_del(SimpleDevs);
	cdev_del(SimpleDevs + 1);
	if(simple_class)
		class_destroy(simple_class);
	unregister_chrdev_region(MKDEV(simple_major, 0), 2);
}


module_init(simple_init);
module_exit(simple_cleanup);
