## gpio_set_value(gpio, value)

	static void _gpiod_set_raw_value(struct gpio_desc *desc, bool value)
	  {
	  ¦       struct gpio_chip¦       *chip;
	  
	  ¦       chip = desc->chip;
	  ¦       trace_gpio_value(desc_to_gpio(desc), 0, value);
	  ¦       if (test_bit(FLAG_OPEN_DRAIN, &desc->flags))
	  ¦       ¦       _gpio_set_open_drain_value(desc, value);
	  ¦       else if (test_bit(FLAG_OPEN_SOURCE, &desc->flags))
	  ¦       ¦       _gpio_set_open_source_value(desc, value);
	  ¦       else
	  ¦       		chip->set(chip, gpio_chip_hwgpio(desc), value);
	  }

-------------------------------------------------------------------------

	struct gpio_desc {
	¦       struct gpio_chip¦       *chip;
	¦       unsigned long¦  ¦       flags;
	/* flag symbols are bit numbers */
	#define FLAG_REQUESTED¦ 0
	#define FLAG_IS_OUT¦    1
	#define FLAG_EXPORT¦    2¦      /* protected by sysfs_lock */
	#define FLAG_SYSFS¦     3¦      /* exported via /sys/class/gpio/control */
	#define FLAG_TRIG_FALL¦ 4¦      /* trigger on falling edge */
	#define FLAG_TRIG_RISE¦ 5¦      /* trigger on rising edge */
	#define FLAG_ACTIVE_LOW¦6¦      /* value has active low */
	#define FLAG_OPEN_DRAIN¦7¦      /* Gpio is open drain type */
	#define FLAG_OPEN_SOURCE 8¦     /* Gpio is open source type */
	#define FLAG_USED_AS_IRQ 9¦     /* GPIO is connected to an IRQ */
	
	#define ID_SHIFT¦       16¦     /* add new flags before this one */
	
	#define GPIO_FLAGS_MASK¦¦       ((1 << ID_SHIFT) - 1)
	#define GPIO_TRIGGER_MASK¦      (BIT(FLAG_TRIG_FALL) | 		BIT(FLAG_TRIG_RISE))	
	¦       const char¦     ¦       *label;
	};

-----------------------------------------------
	static int __gpiod_request(struct gpio_desc *desc, const char *label)
	{
	¦       struct gpio_chip	       *chip = desc->chip;
	¦       int					       status;
	¦       unsigned long			flags;
	}
	¦       spin_lock_irqsave(&gpio_lock, flags);
	  
	¦       /* NOTE:  gpio_request() can be called in early boot,
	¦        * before IRQs are enabled, for non-sleeping (SOC) GPIOs.
	¦        */
	  
	¦       if (test_and_set_bit(FLAG_REQUESTED, &desc->flags) == 0) { 
	¦       ¦       desc_set_label(desc, label ? : "?");
	¦       ¦       status = 0; 
	¦       } else {
	¦       ¦       status = -EBUSY;
	¦       ¦       goto done;
	¦       }
	
	¦       if (chip->request) {
	¦       ¦       /* chip->request may sleep */
	¦       ¦       spin_unlock_irqrestore(&gpio_lock, flags);
	¦       ¦       status = chip->request(chip, gpio_chip_hwgpio(desc));
	¦       ¦       spin_lock_irqsave(&gpio_lock, flags);
	
	¦       ¦       if (status < 0) { 
	¦       ¦       ¦       desc_set_label(desc, NULL);
	¦       ¦       ¦       clear_bit(FLAG_REQUESTED, &desc->flags);
	¦       ¦       ¦       goto done;
	¦       ¦       }
	¦       }
	¦       if (chip->get_direction) {
	¦       ¦       /* chip->get_direction may sleep */
	¦       ¦       spin_unlock_irqrestore(&gpio_lock, flags);
	¦       ¦       gpiod_get_direction(desc);
	¦       ¦       spin_lock_irqsave(&gpio_lock, flags);
	¦       }
	done:
	¦       spin_unlock_irqrestore(&gpio_lock, flags);
	¦       return status;
	}



a few days ago i have coded some code about led driver to control led of a wifi. 
because there is only one led to control both lb and hb led, so that i need to 
read the source code about gpio.
gpio is just a rule that u are suggeseted to obey. cause there is only one gpio, 
so i break the rule. when registing gpio the second time, it will cause an error
of gpio ebusy(ret = -16), but i just ignore that to set gpio(do not learn that).
when request gpio, there is a flag in gpio_desc will change to set the gpio busy,
that is why cause ebusy. 
just record to have a rest.
