
//typedef.
// typedef 的功能是定义新的类型。下面定义了ioctl_cmd_handler的类型。


typedef int (*ioctl_cmd_handler)(
  ¦       ¦       struct hw *rwnx_hw,
  ¦       ¦       struct ioctl_cfg *cfg,
  ¦       ¦       struct iwreq *iwr);
/*
* typedef  指向函数的指针， ioctl_cmd_handler, 返回值为 int 类型， 参数为
* (struct hw *rwnx_hw,
* struct ioctl_cfg *cfg,
* truct iwreq *iwr)
*/

static ioctl_cmd_handler ioctl_cmd_set1[] =
  {
  ¦       ioctl_do_ate_start,/* 0x0000 */
  ¦       ioctl_do_ate_stop,/* 0x0001 */
  };

 //set like that were stored in settables, we use a while loop to find the cmd we need.
  
  
  
  
  //today I met a problem about pointer and array. to figure it out, i just went back to have 
  //a review about that.
  
  //in c language, pointer can be used as array based on pointer's type.
  int *p = 3;
  //we get p's  value p = &(*p) = 0x????
// (0x????)'s value = 3

//数组指针   指向数组的指针 指针指向数组的首地址 即数组类型的指针
a = {3, 4, 5};
int *p = a;

//指针数组   存储指针的数组  即数组 每个值存的是相应的指针
  int *q[3] = {3, 4, 5};

a[1] == 4;
q[1] == 4;

//&a+1 @&a 是类型为a的指向a的指针
  //a+1 @a 是首地址
  //p+1 @p  类型为int的指向a的指针
