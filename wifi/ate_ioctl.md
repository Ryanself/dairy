## learn ate_tool ioctl()

  typedef int (*ioctl_cmd_handler)(
    struct rwnx_hw *rwnx_hw,
    struct rwnx_ioctl_cfg *cfg,
    struct iwreq *iwr);
    )
    
    static ioctl_cmd_handler ioctl_cmd_set[]=
    {
      ioctl_do_ate_start,/* 0x0000 */
      ioctl_do_ate_stop,/* 0x0001 */
      ioctl_do_ate_tx_start,/* 0x0002 */
    }
    
    
    struct ioctl_cmd_table{
          ioctl_cmd_handler *cmd_set;
          int¦    cmd_set_size;
          int¦    cmd_offset;
    };
    
    static struct ioctl_cmd_table ioctl_cmd_tables[] = {
    {
        ioctl_cmd_set1,
        sizeof(ioctl_cmd_set1) / sizeof(ioctl_cmd_handler),
        0x0,
    },
    {
        ioctl_cmd_set2,
        sizeof(ioctl_cmd_set2) / sizeof(ioctl_cmd_handler),
        0x0,
    },
   /*
   * 按块放入cmd_tables
   */
    
    static int rwnx_ioctl_cmd_traversal(struct rwnx_hw *rwnx_hw,
    ¦       ¦       struct rwnx_ioctl_cfg *cfg,
    ¦       ¦       struct iwreq *iwr)
    {
    ..
    while (table_index < (sizeof(ioctl_cmd_tables) / sizeof(struct ioctl_cmd_table)))
    {
    ...
    if (target_handler[cmd_index] != NULL)
    ¦       ¦       ¦       ¦       status = (*target_handler[cmd_index])(rwnx_hw, cfg, iwr);
    ¦       ¦       ¦       break;
    ...
    }
    }
    /*
    * 在此循环中查找出对应cmd的方法，并调用。
    * @*target_handler: ioctl_cmd_set[],
    * @cmd_index: 计算得到的offset-index，
    * @rwnx_hw, cfg, iw: 方法输入的参数，调用cmd时传入。
    */
    
    

