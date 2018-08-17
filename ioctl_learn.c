
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
