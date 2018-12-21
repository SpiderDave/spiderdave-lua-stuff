local candles = {
    {x=0x340, y=0x90, area = {0x00,0x03,0x00,0x00}, floor=0xc9, location="Alba", },
    {x=0x350, y=0x90, area = {0x00,0x03,0x00,0x00}, floor=0xc9, location="Alba", },
    {x=0x1a0, y=0xa0, area = {0x00,0x03,0x00,0x00}, floor=0xc9, location="Alba", },
    {x=0x110, y=0x90, area = {0x00,0x03,0x00,0x00}, floor=0xc9, location="Alba", },
    {x=0xa0, y=0x90, area = {0x00,0x03,0x00,0x00}, floor=0xc9, location="Alba", },
    {x=0xb0, y=0x90, area = {0x00,0x03,0x00,0x00}, floor=0xc9, location="Alba", },
    {x=0x30, y=0x170, area = {0x00,0x03,0x00,0x00}, floor=0x1a9, location="Alba", },
    {x=0x60, y=0x170, area = {0x00,0x03,0x00,0x00}, floor=0x1a9, location="Alba", },
    {x=0xe0, y=0x170, area = {0x00,0x03,0x00,0x00}, floor=0x1a9, location="Alba", },
    {x=0x110, y=0x170, area = {0x00,0x03,0x00,0x00}, floor=0x1a9, location="Alba", },
    {x=0x180, y=0x170, area = {0x00,0x03,0x00,0x00}, floor=0x1a9, location="Alba", },
    {x=0x210, y=0x180, area = {0x00,0x03,0x00,0x00}, floor=0x1a9, location="Alba", },
    {x=0x310, y=0x170, area = {0x00,0x03,0x00,0x00}, floor=0x1a9, location="Alba", },
    {x=0x340, y=0x170, area = {0x00,0x03,0x00,0x00}, floor=0x1a9, location="Alba", },
    {x=0x50, y=0x90, area = {0x00,0x10,0x00,0x01}, floor=0xc9, location="(room)", },
    {x=0x80, y=0x90, area = {0x00,0x10,0x00,0x01}, floor=0xc9, location="(room)", },
    {x=0xc0, y=0x90, area = {0x00,0x10,0x00,0x01}, floor=0xc9, location="(room)", },
    {x=0x290, y=0x1f0, area = {0x00,0x03,0x00,0x00}, floor=0x229, location="Alba", },
    {x=0x2c0, y=0x1f0, area = {0x00,0x03,0x00,0x00}, floor=0x229, location="Alba", },
    {x=0x210, y=0x200, area = {0x00,0x03,0x00,0x00}, floor=0x229, location="Alba", },
    {x=0x1e0, y=0x250, area = {0x00,0x03,0x00,0x00}, floor=0x289, location="Alba", },
    {x=0x110, y=0x260, area = {0x00,0x03,0x00,0x00}, floor=0x289, location="Alba", },
    {x=0x30, y=0x230, area = {0x00,0x03,0x00,0x00}, floor=0x289, location="Alba", },
    {x=0x60, y=0x230, area = {0x00,0x03,0x00,0x00}, floor=0x289, location="Alba", },
    {x=0xe0, y=0x1e0, area = {0x00,0x03,0x00,0x00}, floor=0x209, location="Alba", },
    {x=0x1a0, y=0xa0, area = {0x03,0x02,0x01,0x41}, floor=0xc9, location="Sadam Woods", },
    {x=0x160, y=0xb0, area = {0x03,0x02,0x01,0x41}, floor=0xc9, location="Sadam Woods", },
    {x=0x140, y=0xa0, area = {0x03,0x02,0x01,0x41}, floor=0xc9, location="Sadam Woods", },
    {x=0xc0, y=0xb0, area = {0x03,0x02,0x01,0x41}, floor=0xc9, location="Sadam Woods", },
    {x=0xe0, y=0x120, area = {0x03,0x02,0x00,0x41}, floor=0x149, location="Sadam Woods", },
    {x=0xf0, y=0x120, area = {0x03,0x02,0x00,0x41}, floor=0x149, location="Sadam Woods", },
    {x=0x1c0, y=0xf0, area = {0x03,0x02,0x00,0x41}, floor=0x149, location="Sadam Woods", },
    {x=0x390, y=0xb0, area = {0x03,0x01,0x00,0x41}, floor=0xc9, location="Storigori Graveyard", },
    {x=0x350, y=0xb0, area = {0x03,0x01,0x00,0x41}, floor=0xc9, location="Storigori Graveyard", },
    {x=0x2a0, y=0xb0, area = {0x03,0x01,0x00,0x41}, floor=0xc9, location="Storigori Graveyard", },
    {x=0x1f0, y=0xb0, area = {0x03,0x01,0x00,0x41}, floor=0xc9, location="Storigori Graveyard", },
    {x=0xb0, y=0xb0, area = {0x03,0x01,0x00,0x41}, floor=0xc9, location="Storigori Graveyard", },
    {x=0x100, y=0xb0, area = {0x03,0x01,0x00,0x41}, floor=0xc9, location="Storigori Graveyard", },
    {x=0x60, y=0xb0, area = {0x03,0x01,0x00,0x41}, floor=0xc9, location="Storigori Graveyard", },
    {x=0x60, y=0x90, area = {0x00,0x00,0x00,0x00}, floor=0xc9, location="Jova", },
    {x=0x30, y=0x90, area = {0x00,0x00,0x00,0x00}, floor=0xc9, location="Jova", },
    {x=0x110, y=0x90, area = {0x00,0x00,0x00,0x00}, floor=0xc9, location="Jova", },
    {x=0x180, y=0x90, area = {0x00,0x00,0x00,0x00}, floor=0xc9, location="Jova", },
    {x=0x1e0, y=0xa0, area = {0x00,0x00,0x00,0x00}, floor=0xc9, location="Jova", },
    {x=0x50, y=0x90, area = {0x00,0x09,0x00,0x01}, floor=0xc9, location="(room)", },
    {x=0x80, y=0x90, area = {0x00,0x09,0x00,0x01}, floor=0xc9, location="(room)", },
    {x=0x110, y=0x120, area = {0x00,0x00,0x00,0x00}, floor=0x1a9, location="Jova", },
    {x=0x210, y=0x120, area = {0x00,0x00,0x00,0x00}, floor=0x149, location="Jova", },
    {x=0x280, y=0x180, area = {0x00,0x00,0x00,0x00}, floor=0x1a9, location="Jova", },
    {x=0x340, y=0x90, area = {0x00,0x00,0x00,0x00}, floor=0xc9, location="Jova", },
    {x=0x350, y=0x90, area = {0x00,0x00,0x00,0x00}, floor=0xc9, location="Jova", },
    {x=0x370, y=0x70, area = {0x02,0x00,0x00,0x41}, floor=0xa9, location="Jova Woods", },
    {x=0x390, y=0x80, area = {0x02,0x00,0x00,0x41}, floor=0xa9, location="Jova Woods", },
    {x=0x1f0, y=0x50, area = {0x02,0x00,0x00,0x41}, floor=0x89, location="Jova Woods", },
    {x=0x210, y=0x50, area = {0x02,0x00,0x00,0x41}, floor=0x89, location="Jova Woods", },
    {x=0x230, y=0x50, area = {0x02,0x00,0x00,0x41}, floor=0x89, location="Jova Woods", },
    {x=0x2c0, y=0x330, area = {0x01,0x06,0x01,0x81}, floor=0x369, location="Laruba", },
    {x=0x20, y=0x320, area = {0x01,0x06,0x01,0x81}, floor=0x349, location="Laruba", },
    {x=0xc0, y=0xa0, area = {0x04,0x00,0x00,0x41}, floor=0xc9, location="Vrad Mountain", },
    {x=0x70, y=0xb0, area = {0x04,0x00,0x00,0x41}, floor=0xc9, location="Vrad Mountain", },
    {x=0x1b0, y=0x80, area = {0x02,0x00,0x01,0x41}, floor=0x99, location="South Bridge", },
    {x=0x10, y=0x80, area = {0x02,0x00,0x01,0x41}, floor=0xc9, location="South Bridge", },
    {x=0xf0, y=0x60, area = {0x02,0x00,0x01,0x41}, floor=0x99, location="South Bridge", },
    {x=0x140, y=0x60, area = {0x02,0x00,0x01,0x41}, floor=0x99, location="South Bridge", },
    {x=0x240, y=0x60, area = {0x02,0x00,0x01,0x41}, floor=0x99, location="South Bridge", },
    {x=0x2b0, y=0x70, area = {0x02,0x00,0x01,0x41}, floor=0xb1, location="South Bridge", },
    {x=0x310, y=0x70, area = {0x02,0x00,0x01,0x41}, floor=0x99, location="South Bridge", },
    {x=0x80, y=0xa0, area = {0x02,0x00,0x02,0x41}, floor=0xc9, location="Veros Woods", },
    {x=0xd0, y=0xa0, area = {0x02,0x00,0x02,0x41}, floor=0xc9, location="Veros Woods", },
    {x=0x120, y=0xa0, area = {0x02,0x00,0x02,0x41}, floor=0xc9, location="Veros Woods", },
    {x=0x60, y=0x70, area = {0x02,0x00,0x03,0x41}, floor=0xa9, location="Veros Woods", },
    {x=0x30, y=0xf0, area = {0x02,0x00,0x03,0x41}, floor=0x149, location="Veros Woods", },
    {x=0x40, y=0xf0, area = {0x02,0x00,0x03,0x41}, floor=0x149, location="Veros Woods", },
    {x=0x50, y=0xf0, area = {0x02,0x00,0x03,0x41}, floor=0x149, location="Veros Woods", },
    {x=0x120, y=0x120, area = {0x02,0x00,0x03,0x41}, floor=0x169, location="Veros Woods", },
    {x=0x1a0, y=0x170, area = {0x02,0x00,0x03,0x41}, floor=0x189, location="Veros Woods", },
    {x=0x150, y=0x90, area = {0x00,0x01,0x00,0x00}, floor=0xc9, location="Veros", },
    {x=0x180, y=0x90, area = {0x00,0x01,0x00,0x00}, floor=0xc9, location="Veros", },
    {x=0xd0, y=0x90, area = {0x00,0x0b,0x00,0x01}, floor=0xc9, location="(room)", },
    {x=0x90, y=0x90, area = {0x00,0x0b,0x00,0x01}, floor=0xc9, location="(room)", },
    {x=0xf0, y=0x40, area = {0x02,0x03,0x01,0x41}, floor=0x69, location="Dabis Path", },
    {x=0x120, y=0x40, area = {0x02,0x03,0x01,0x41}, floor=0x69, location="Dabis Path", },
    {x=0x150, y=0x40, area = {0x02,0x03,0x01,0x41}, floor=0x69, location="Dabis Path", },
    {x=0x50, y=0x80, area = {0x02,0x01,0x00,0x41}, floor=0xa9, location="Denis Woods", },
    {x=0x190, y=0x80, area = {0x02,0x00,0x03,0x41}, floor=0xa9, location="Veros Woods", },
    {x=0x150, y=0x80, area = {0x02,0x00,0x03,0x41}, floor=0xa9, location="Veros Woods", },
    {x=0x20, y=0x170, area = {0x02,0x03,0x00,0x41}, floor=0x1a9, location="Dabis Path", },
    {x=0x110, y=0x160, area = {0x02,0x03,0x00,0x41}, floor=0x189, location="Dabis Path", },
    {x=0x1c0, y=0xa0, area = {0x02,0x03,0x00,0x41}, floor=0xc9, location="Dabis Path", },
    {x=0x180, y=0x40, area = {0x02,0x03,0x00,0x41}, floor=0x69, location="Dabis Path", },
    {x=0x110, y=0x80, area = {0x02,0x03,0x02,0x41}, floor=0xc9, location="Aljiba Woods", },
    {x=0x1d0, y=0x60, area = {0x02,0x03,0x02,0x41}, floor=0x89, location="Aljiba Woods", },
    {x=0x50, y=0x110, area = {0x02,0x03,0x03,0x41}, floor=0x149, location="Aljiba Woods", },
    {x=0x60, y=0x110, area = {0x02,0x03,0x03,0x41}, floor=0x149, location="Aljiba Woods", },
    {x=0x120, y=0x130, area = {0x02,0x03,0x03,0x41}, floor=0x169, location="Aljiba Woods", },
    {x=0x1a0, y=0x160, area = {0x02,0x03,0x03,0x41}, floor=0x189, location="Aljiba Woods", },
    {x=0x70, y=0x50, area = {0x02,0x05,0x00,0x41}, floor=0xa9, location="Aljiba Woods", },
    {x=0x60, y=0x50, area = {0x02,0x05,0x00,0x41}, floor=0xa9, location="Aljiba Woods", },
    {x=0x50, y=0x50, area = {0x02,0x05,0x00,0x41}, floor=0xa9, location="Aljiba Woods", },
    {x=0x3b0, y=0x40, area = {0x02,0x05,0x00,0x41}, floor=0x69, location="Aljiba Woods", },
    {x=0x3d0, y=0x40, area = {0x02,0x05,0x00,0x41}, floor=0xc9, location="Aljiba Woods", },
    {x=0x2b0, y=0xa0, area = {0x02,0x05,0x00,0x41}, floor=0xc9, location="Aljiba Woods", },
    {x=0x350, y=0xa0, area = {0x02,0x05,0x00,0x41}, floor=0xc9, location="Aljiba Woods", },
    {x=0x40, y=0x60, area = {0x02,0x02,0x00,0x41}, floor=0x89, location="Aljiba Woods", },
    {x=0x180, y=0x70, area = {0x02,0x02,0x00,0x41}, floor=0xa9, location="Aljiba Woods", },
    {x=0xd0, y=0xa0, area = {0x00,0x0c,0x00,0x01}, floor=0xc9, location="(room)", },
    {x=0xe0, y=0x60, area = {0x00,0x0d,0x00,0x01}, floor=0xc9, location="(room)", },
    {x=0xd0, y=0x70, area = {0x00,0x0d,0x00,0x01}, floor=0xc9, location="(room)", },
    {x=0xc0, y=0x80, area = {0x00,0x0d,0x00,0x01}, floor=0xc9, location="(room)", },
    {x=0x50, y=0x90, area = {0x00,0x0e,0x00,0x01}, floor=0xc9, location="(room)", },
    {x=0x90, y=0x170, area = {0x00,0x0e,0x01,0x01}, floor=0x1a9, location="(room)", },
    {x=0x50, y=0x170, area = {0x00,0x0e,0x01,0x01}, floor=0x1a9, location="(room)", },
    {x=0x40, y=0x70, area = {0x00,0x02,0x00,0x00}, floor=0xc9, location="Aljiba", },
    {x=0x50, y=0x70, area = {0x00,0x02,0x00,0x00}, floor=0xc9, location="Aljiba", },
    {x=0x60, y=0x70, area = {0x00,0x02,0x00,0x00}, floor=0xc9, location="Aljiba", },
    {x=0xf0, y=0x90, area = {0x02,0x02,0x00,0x41}, floor=0xc9, location="Aljiba Woods", },
    {x=0xc0, y=0x60, area = {0x01,0x02,0x00,0x80}, floor=0xc9, location="Rover (door)", },
    {x=0x90, y=0x60, area = {0x01,0x02,0x00,0x80}, floor=0xc9, location="Rover (door)", },
    {x=0x60, y=0x60, area = {0x01,0x02,0x00,0x80}, floor=0xc9, location="Rover (door)", },
    {x=0x30, y=0x60, area = {0x01,0x02,0x00,0x80}, floor=0xc9, location="Rover (door)", },
    {x=0x2c0, y=0x260, area = {0x01,0x08,0x00,0x81}, floor=0x289, location="Rover", },
    {x=0x60, y=0x260, area = {0x01,0x08,0x01,0x81}, floor=0x289, location="Rover", },
    {x=0x110, y=0x260, area = {0x01,0x08,0x01,0x81}, floor=0x289, location="Rover", },
    {x=0x220, y=0x250, area = {0x01,0x08,0x01,0x81}, floor=0x289, location="Rover", },
    {x=0x3d0, y=0x200, area = {0x01,0x08,0x01,0x81}, floor=0x229, location="Rover", },
    {x=0x3c0, y=0x200, area = {0x01,0x08,0x01,0x81}, floor=0x229, location="Rover", },
    {x=0x40, y=0x250, area = {0x01,0x08,0x00,0x81}, floor=0x289, location="Rover", },
    {x=0x100, y=0x250, area = {0x01,0x08,0x00,0x81}, floor=0x289, location="Rover", },
    {x=0x180, y=0x250, area = {0x01,0x08,0x00,0x81}, floor=0x289, location="Rover", },
    {x=0x1e0, y=0x250, area = {0x01,0x08,0x00,0x81}, floor=0x289, location="Rover", },
    {x=0xe0, y=0x200, area = {0x01,0x08,0x01,0x81}, floor=0x229, location="Rover", },
    {x=0x1b0, y=0x1a0, area = {0x01,0x08,0x01,0x81}, floor=0x1c9, location="Rover", },
    {x=0x280, y=0x150, area = {0x01,0x08,0x01,0x81}, floor=0x1a9, location="Rover", },
    {x=0x270, y=0x160, area = {0x01,0x08,0x01,0x81}, floor=0x1a9, location="Rover", },
    {x=0x260, y=0x170, area = {0x01,0x08,0x01,0x81}, floor=0x1a9, location="Rover", },
    {x=0x250, y=0x180, area = {0x01,0x08,0x01,0x81}, floor=0x1a9, location="Rover", },
    {x=0x2c0, y=0x60, area = {0x01,0x08,0x01,0x81}, floor=0x89, location="Rover", },
    {x=0x3d0, y=0x60, area = {0x01,0x08,0x01,0x81}, floor=0x89, location="Rover", },
    {x=0x3c0, y=0x60, area = {0x01,0x08,0x01,0x81}, floor=0x89, location="Rover", },
    {x=0xa0, y=0x160, area = {0x02,0x05,0x01,0x41}, floor=0x199, location="Yuba Lake", },
    {x=0x170, y=0xa0, area = {0x02,0x05,0x00,0x41}, floor=0xc9, location="Aljiba Woods", },
    {x=0x1b0, y=0x60, area = {0x02,0x04,0x01,0x41}, floor=0xa9, location="Denis Woods", },
    {x=0x20, y=0x240, area = {0x01,0x07,0x00,0x81}, floor=0x289, location="Berkeley", },
    {x=0x70, y=0x1d0, area = {0x01,0x07,0x00,0x81}, floor=0x209, location="Berkeley", },
    {x=0x110, y=0x1b0, area = {0x01,0x07,0x00,0x81}, floor=0x1e9, location="Berkeley", },
    {x=0x250, y=0x1b0, area = {0x01,0x07,0x00,0x81}, floor=0x1e9, location="Berkeley", },
    {x=0x2d0, y=0x140, area = {0x01,0x07,0x00,0x81}, floor=0x189, location="Berkeley", },
    {x=0x100, y=0x150, area = {0x01,0x07,0x00,0x81}, floor=0x189, location="Berkeley", },
    {x=0x80, y=0x120, area = {0x01,0x07,0x00,0x81}, floor=0x149, location="Berkeley", },
    {x=0x50, y=0x140, area = {0x01,0x07,0x00,0x81}, floor=0x189, location="Berkeley", },
    {x=0x50, y=0xa0, area = {0x01,0x07,0x00,0x81}, floor=0xe9, location="Berkeley", },
    {x=0x150, y=0x60, area = {0x01,0x07,0x00,0x81}, floor=0x89, location="Berkeley", },
    {x=0x1d0, y=0x60, area = {0x01,0x07,0x00,0x81}, floor=0x89, location="Berkeley", },
    {x=0x150, y=0x40, area = {0x01,0x07,0x01,0x81}, floor=0x69, location="Berkeley", },
    {x=0x1d0, y=0x40, area = {0x01,0x07,0x01,0x81}, floor=0x69, location="Berkeley", },
    {x=0x140, y=0xa0, area = {0x01,0x07,0x01,0x81}, floor=0xc9, location="Berkeley", },
    {x=0x2c0, y=0x40, area = {0x01,0x07,0x01,0x81}, floor=0xc9, location="Berkeley", },
    {x=0x120, y=0x1a0, area = {0x01,0x07,0x01,0x81}, floor=0x1c9, location="Berkeley", },
    {x=0x2d0, y=0x140, area = {0x01,0x07,0x01,0x81}, floor=0x169, location="Berkeley", },
    {x=0x2c0, y=0x140, area = {0x01,0x07,0x01,0x81}, floor=0x169, location="Berkeley", },
    {x=0x130, y=0x140, area = {0x01,0x07,0x01,0x81}, floor=0x169, location="Berkeley", },
    {x=0x60, y=0x50, area = {0x01,0x01,0x00,0x80}, floor=0xc9, location="Berkeley (door)", },
    {x=0x90, y=0x50, area = {0x01,0x01,0x00,0x80}, floor=0xc9, location="Berkeley (door)", },
    {x=0xd0, y=0x190, area = {0x00,0x0b,0x00,0x01}, floor=0x1a9, location="(room)", },
    {x=0x3c0, y=0x60, area = {0x00,0x01,0x00,0x00}, floor=0xc9, location="Veros", },
    {x=0x150, y=0x60, area = {0x03,0x00,0x00,0x41}, floor=0xc9, location="Camilla Cemetery", },
    {x=0x2d0, y=0xa0, area = {0x02,0x04,0x00,0x41}, floor=0xc9, location="Denis Woods", },
    {x=0x250, y=0xa0, area = {0x02,0x04,0x00,0x41}, floor=0xd9, location="Denis Woods", },
    {x=0x210, y=0xa0, area = {0x02,0x04,0x00,0x41}, floor=0xc9, location="Denis Woods", },
    {x=0x190, y=0xa0, area = {0x02,0x04,0x00,0x41}, floor=0xc9, location="Denis Woods", },
    {x=0x60, y=0x110, area = {0x00,0x00,0x00,0x00}, floor=0x1a9, location="Jova", },
    {x=0x200, y=0x50, area = {0x02,0x07,0x02,0x41}, floor=0x89, location="Belasco Marsh", },
    {x=0x60, y=0xa0, area = {0x02,0x07,0x01,0x41}, floor=0xc6, location="Dead River", },
    {x=0x160, y=0x90, area = {0x02,0x06,0x00,0x41}, floor=0xc6, location="Dead River???", },
    {x=0x90, y=0x50, area = {0x01,0x03,0x00,0x80}, floor=0xc9, location="Brahm (door)", },
    {x=0x60, y=0x50, area = {0x01,0x03,0x00,0x80}, floor=0xc9, location="Brahm (door)", },
    {x=0x30, y=0x330, area = {0x01,0x09,0x00,0x81}, floor=0x369, location="Brahm", },
    {x=0xb0, y=0x330, area = {0x01,0x09,0x00,0x81}, floor=0x369, location="Brahm", },
    {x=0x120, y=0x1b0, area = {0x01,0x09,0x00,0x81}, floor=0x1e9, location="Brahm", },
    {x=0x140, y=0x1b0, area = {0x01,0x09,0x00,0x81}, floor=0x1e9, location="Brahm", },
    {x=0x90, y=0x200, area = {0x01,0x09,0x00,0x81}, floor=0x249, location="Brahm", },
    {x=0x170, y=0x120, area = {0x01,0x09,0x00,0x81}, floor=0x169, location="Brahm", },
    {x=0x120, y=0x50, area = {0x01,0x09,0x00,0x81}, floor=0x89, location="Brahm", },
    {x=0x90, y=0x50, area = {0x01,0x09,0x00,0x81}, floor=0x89, location="Brahm", },
    {x=0x30, y=0x90, area = {0x01,0x09,0x00,0x81}, floor=0xb3, location="Brahm", },
    {x=0x40, y=0x90, area = {0x01,0x09,0x00,0x81}, floor=0xc9, location="Brahm", },
    {x=0x50, y=0x90, area = {0x01,0x09,0x00,0x81}, floor=0xc9, location="Brahm", },
    {x=0x60, y=0x90, area = {0x01,0x09,0x00,0x81}, floor=0xc9, location="Brahm", },
    {x=0x70, y=0x90, area = {0x01,0x09,0x00,0x81}, floor=0xc9, location="Brahm", },
    {x=0xb0, y=0x60, area = {0x01,0x09,0x01,0x81}, floor=0x89, location="Brahm", },
    {x=0xa0, y=0x60, area = {0x01,0x09,0x01,0x81}, floor=0x89, location="Brahm", },
    {x=0x2e0, y=0x110, area = {0x01,0x09,0x00,0x81}, floor=0x169, location="Brahm", },
    {x=0x260, y=0x230, area = {0x01,0x09,0x00,0x81}, floor=0x269, location="Brahm", },
    {x=0x70, y=0x330, area = {0x01,0x09,0x01,0x81}, floor=0x369, location="Brahm", },
    {x=0x80, y=0x330, area = {0x01,0x09,0x01,0x81}, floor=0x369, location="Brahm", },
    {x=0xe0, y=0x40, area = {0x01,0x09,0x03,0x81}, floor=0x89, location="Brahm", },
    {x=0x2d0, y=0x60, area = {0x04,0x00,0x01,0x41}, floor=0xc9, location="Vrad Mountain", },
    {x=0x280, y=0x50, area = {0x04,0x00,0x01,0x41}, floor=0xa1, location="Vrad Mountain", },
    {x=0x240, y=0x50, area = {0x04,0x00,0x01,0x41}, floor=0x90, location="Vrad Mountain", },
    {x=0x200, y=0x60, area = {0x04,0x00,0x01,0x41}, floor=0xbd, location="Vrad Mountain", },
    {x=0x150, y=0x60, area = {0x04,0x00,0x01,0x41}, floor=0xa8, location="Vrad Mountain", },
    {x=0x1e0, y=0x80, area = {0x04,0x00,0x00,0x41}, floor=0xc9, location="Vrad Mountain", },
    {x=0x140, y=0x80, area = {0x02,0x07,0x00,0x41}, floor=0xc9, location="Dead River", },
    {x=0x60, y=0x50, area = {0x01,0x00,0x00,0x80}, floor=0xc9, location="Laruba (door)", },
    {x=0x90, y=0x50, area = {0x01,0x00,0x00,0x80}, floor=0xc9, location="Laruba (door)", },
    {x=0x70, y=0x170, area = {0x01,0x06,0x00,0x81}, floor=0x1a9, location="Laruba", },
    {x=0xf0, y=0x170, area = {0x01,0x06,0x00,0x81}, floor=0x1a9, location="Laruba", },
    {x=0x370, y=0x110, area = {0x01,0x06,0x00,0x81}, floor=0x149, location="Laruba", },
    {x=0x240, y=0xd0, area = {0x01,0x06,0x00,0x81}, floor=0x129, location="Laruba", },
    {x=0x20, y=0xc0, area = {0x01,0x06,0x00,0x81}, floor=0xe9, location="Laruba", },
    {x=0x100, y=0x80, area = {0x01,0x06,0x00,0x81}, floor=0xc9, location="Laruba", },
    {x=0x110, y=0x70, area = {0x01,0x06,0x00,0x81}, floor=0xc9, location="Laruba", },
    {x=0x120, y=0x60, area = {0x01,0x06,0x00,0x81}, floor=0xc9, location="Laruba", },
    {x=0x10, y=0x30, area = {0x01,0x06,0x00,0x81}, floor=0x49, location="Laruba", },
    {x=0x20, y=0x30, area = {0x01,0x06,0x00,0x81}, floor=0x49, location="Laruba", },
    {x=0x30, y=0x30, area = {0x01,0x06,0x00,0x81}, floor=0x49, location="Laruba", },
    {x=0x3e0, y=0x50, area = {0x01,0x06,0x00,0x81}, floor=0xa9, location="Laruba", },
    {x=0xd0, y=0x100, area = {0x01,0x06,0x01,0x81}, floor=0x189, location="Laruba", },
    {x=0x1d0, y=0x90, area = {0x01,0x06,0x01,0x81}, floor=0xc9, location="Laruba", },
    {x=0x190, y=0x30, area = {0x01,0x06,0x01,0x81}, floor=0x69, location="Laruba", },
    {x=0x1d0, y=0x30, area = {0x01,0x06,0x01,0x81}, floor=0x69, location="Laruba", },
    {x=0x220, y=0x30, area = {0x01,0x06,0x01,0x81}, floor=0x69, location="Laruba", },
    {x=0x290, y=0x60, area = {0x01,0x06,0x01,0x81}, floor=0xc9, location="Laruba", },
    {x=0x2a0, y=0x60, area = {0x01,0x06,0x01,0x81}, floor=0xc9, location="Laruba", },
    {x=0x2b0, y=0x60, area = {0x01,0x06,0x01,0x81}, floor=0xc9, location="Laruba", },
    {x=0x2d0, y=0x1d0, area = {0x01,0x06,0x01,0x81}, floor=0x209, location="Laruba", },
    {x=0x2a0, y=0x1d0, area = {0x01,0x06,0x01,0x81}, floor=0x209, location="Laruba", },
    {x=0x260, y=0x1d0, area = {0x01,0x06,0x01,0x81}, floor=0x209, location="Laruba", },
    {x=0x230, y=0x2b0, area = {0x01,0x06,0x01,0x81}, floor=0x2e9, location="Laruba", },
    {x=0x190, y=0x310, area = {0x01,0x06,0x01,0x81}, floor=0x349, location="Laruba", },
    {x=0x210, y=0x310, area = {0x01,0x06,0x01,0x81}, floor=0x349, location="Laruba", },
    {x=0x120, y=0x320, area = {0x01,0x06,0x01,0x81}, floor=0x369, location="Laruba", },
    {x=0xb0, y=0x330, area = {0x01,0x06,0x01,0x81}, floor=0x35c, location="Laruba", },
    {x=0x340, y=0x90, area = {0x03,0x00,0x01,0x41}, floor=0xc9, location="Joma Marsh", },
    {x=0x2f0, y=0x90, area = {0x03,0x00,0x01,0x41}, floor=0xc9, location="Joma Marsh", },
    {x=0x2a0, y=0x90, area = {0x03,0x00,0x01,0x41}, floor=0xc9, location="Joma Marsh", },
    {x=0x250, y=0x90, area = {0x03,0x00,0x01,0x41}, floor=0xc9, location="Joma Marsh", },
    {x=0x210, y=0x90, area = {0x03,0x00,0x01,0x41}, floor=0xc9, location="Joma Marsh", },
    {x=0x1d0, y=0x90, area = {0x03,0x00,0x01,0x41}, floor=0xc9, location="Joma Marsh", },
    {x=0x180, y=0x90, area = {0x03,0x00,0x01,0x41}, floor=0xc9, location="Joma Marsh", },
    {x=0x140, y=0x90, area = {0x03,0x00,0x01,0x41}, floor=0xc9, location="Joma Marsh", },
    {x=0x100, y=0x90, area = {0x03,0x00,0x01,0x41}, floor=0xc9, location="Joma Marsh", },
    {x=0xb0, y=0x90, area = {0x03,0x00,0x01,0x41}, floor=0xc9, location="Joma Marsh", },
    {x=0x60, y=0x90, area = {0x03,0x00,0x01,0x41}, floor=0xc9, location="Joma Marsh", },
    {x=0x80, y=0x90, area = {0x03,0x03,0x00,0x41}, floor=0xc9, location="Joma Marsh", },
    {x=0xc0, y=0x90, area = {0x03,0x03,0x00,0x41}, floor=0xc9, location="Joma Marsh", },
    {x=0x100, y=0x90, area = {0x03,0x03,0x00,0x41}, floor=0xc9, location="Joma Marsh", },
    {x=0x130, y=0x90, area = {0x03,0x03,0x00,0x41}, floor=0xc9, location="Joma Marsh", },
    {x=0x160, y=0x90, area = {0x03,0x03,0x00,0x41}, floor=0xc9, location="Joma Marsh", },
    {x=0x190, y=0x90, area = {0x03,0x03,0x00,0x41}, floor=0xc9, location="Joma Marsh", },
    {x=0x1c0, y=0x90, area = {0x03,0x03,0x00,0x41}, floor=0xc9, location="Joma Marsh", },
    {x=0x200, y=0x90, area = {0x03,0x03,0x00,0x41}, floor=0xc9, location="Joma Marsh", },
    {x=0x240, y=0x90, area = {0x03,0x03,0x00,0x41}, floor=0xc9, location="Joma Marsh", },
    {x=0x280, y=0x90, area = {0x03,0x03,0x00,0x41}, floor=0xc9, location="Joma Marsh", },
    {x=0x2c0, y=0x90, area = {0x03,0x03,0x00,0x41}, floor=0xc9, location="Joma Marsh", },
    {x=0x330, y=0x90, area = {0x03,0x03,0x00,0x41}, floor=0xc9, location="Joma Marsh", },
    {x=0x370, y=0x90, area = {0x03,0x03,0x00,0x41}, floor=0xc9, location="Joma Marsh", },
    {x=0x3b0, y=0x90, area = {0x03,0x03,0x00,0x41}, floor=0xc9, location="Joma Marsh", },
    {x=0x70, y=0x90, area = {0x03,0x03,0x01,0x41}, floor=0xb6, location="Joma Marsh", },
    {x=0x160, y=0x80, area = {0x03,0x03,0x01,0x41}, floor=0xb9, location="Joma Marsh", },
    {x=0x240, y=0x50, area = {0x03,0x03,0x01,0x41}, floor=0xc1, location="Joma Marsh", },
    {x=0x350, y=0x90, area = {0x03,0x03,0x01,0x41}, floor=0xc9, location="Joma Marsh", },
    {x=0x2c0, y=0x50, area = {0x03,0x03,0x01,0x41}, floor=0xc9, location="Joma Marsh", },
    {x=0x290, y=0x50, area = {0x03,0x03,0x01,0x41}, floor=0xc9, location="Joma Marsh", },
    {x=0x30, y=0x240, area = {0x03,0x03,0x02,0x41}, floor=0x289, location="Debious Woods", },
    {x=0x20, y=0x240, area = {0x03,0x03,0x02,0x41}, floor=0x289, location="Debious Woods", },
    {x=0xd0, y=0x190, area = {0x03,0x03,0x02,0x41}, floor=0x1c9, location="Debious Woods", },
    {x=0x140, y=0x170, area = {0x03,0x03,0x02,0x41}, floor=0x1c9, location="Debious Woods", },
    {x=0x1b0, y=0x120, area = {0x03,0x03,0x02,0x41}, floor=0x149, location="Debious Woods", },
    {x=0x1a0, y=0x120, area = {0x03,0x03,0x02,0x41}, floor=0x149, location="Debious Woods", },
    {x=0x1b0, y=0x110, area = {0x03,0x03,0x02,0x41}, floor=0x149, location="Debious Woods", },
    {x=0x1a0, y=0x110, area = {0x03,0x03,0x02,0x41}, floor=0x149, location="Debious Woods", },
    {x=0x20, y=0x110, area = {0x03,0x03,0x02,0x41}, floor=0x149, location="Debious Woods", },
    {x=0x20, y=0xb0, area = {0x03,0x03,0x02,0x41}, floor=0xe9, location="Debious Woods", },
    {x=0x30, y=0xb0, area = {0x03,0x03,0x02,0x41}, floor=0xe9, location="Debious Woods", },
    {x=0x20, y=0xc0, area = {0x03,0x03,0x02,0x41}, floor=0xe9, location="Debious Woods", },
    {x=0x30, y=0xc0, area = {0x03,0x03,0x02,0x41}, floor=0xe9, location="Debious Woods", },
    {x=0x20, y=0x50, area = {0x03,0x03,0x02,0x41}, floor=0x89, location="Debious Woods", },
    {x=0x30, y=0x50, area = {0x03,0x03,0x02,0x41}, floor=0x89, location="Debious Woods", },
    {x=0x30, y=0x60, area = {0x03,0x03,0x02,0x41}, floor=0x89, location="Debious Woods", },
    {x=0x20, y=0x60, area = {0x03,0x03,0x02,0x41}, floor=0x89, location="Debious Woods", },
    {x=0x20, y=0x70, area = {0x03,0x03,0x02,0x41}, floor=0x89, location="Debious Woods", },
    {x=0x30, y=0x70, area = {0x03,0x03,0x02,0x41}, floor=0x89, location="Debious Woods", },
    {x=0x170, y=0x250, area = {0x03,0x03,0x02,0x41}, floor=0x289, location="Debious Woods", },
    {x=0x1b0, y=0x250, area = {0x03,0x03,0x02,0x41}, floor=0x289, location="Debious Woods", },
    {x=0x220, y=0x240, area = {0x03,0x03,0x02,0x41}, floor=0x289, location="Debious Woods", },
    {x=0x260, y=0x240, area = {0x03,0x03,0x02,0x41}, floor=0x289, location="Debious Woods", },
    {x=0x2b0, y=0x240, area = {0x03,0x03,0x02,0x41}, floor=0x289, location="Debious Woods", },
    {x=0x60, y=0x50, area = {0x01,0x04,0x00,0x80}, floor=0xc9, location="Bodley (door)", },
    {x=0x90, y=0x50, area = {0x01,0x04,0x00,0x80}, floor=0xc9, location="Bodley (door)", },
    {x=0xb0, y=0x250, area = {0x01,0x0a,0x00,0x81}, floor=0x289, location="Bodley", },
    {x=0x140, y=0x230, area = {0x01,0x0a,0x00,0x81}, floor=0x289, location="Bodley", },
    {x=0x150, y=0x240, area = {0x01,0x0a,0x00,0x81}, floor=0x289, location="Bodley", },
    {x=0x160, y=0x250, area = {0x01,0x0a,0x00,0x81}, floor=0x289, location="Bodley", },
    {x=0x280, y=0x1f0, area = {0x01,0x0a,0x00,0x81}, floor=0x209, location="Bodley", },
    {x=0x2c0, y=0x1f0, area = {0x01,0x0a,0x00,0x81}, floor=0x209, location="Bodley", },
    {x=0x300, y=0x1f0, area = {0x01,0x0a,0x00,0x81}, floor=0x209, location="Bodley", },
    {x=0x340, y=0x1f0, area = {0x01,0x0a,0x00,0x81}, floor=0x209, location="Bodley", },
    {x=0x380, y=0x1f0, area = {0x01,0x0a,0x00,0x81}, floor=0x209, location="Bodley", },
    {x=0x40, y=0x210, area = {0x01,0x0a,0x01,0x81}, floor=0x289, location="Bodley", },
    {x=0x20, y=0x180, area = {0x01,0x0a,0x01,0x81}, floor=0x1a9, location="Bodley", },
    {x=0x130, y=0x190, area = {0x01,0x0a,0x01,0x81}, floor=0x1a9, location="Bodley", },
    {x=0x290, y=0x130, area = {0x01,0x0a,0x01,0x81}, floor=0x1a9, location="Bodley", },
    {x=0x320, y=0x180, area = {0x01,0x0a,0x01,0x81}, floor=0x1a9, location="Bodley", },
    {x=0x3d0, y=0x190, area = {0x01,0x0a,0x01,0x81}, floor=0x209, location="Bodley", },
    {x=0x320, y=0x1f0, area = {0x01,0x0a,0x01,0x81}, floor=0x209, location="Bodley", },
    {x=0x70, y=0x310, area = {0x01,0x0a,0x01,0x81}, floor=0x369, location="Bodley", },
    {x=0x130, y=0x340, area = {0x01,0x0a,0x01,0x81}, floor=0x369, location="Bodley", },
    {x=0x170, y=0x340, area = {0x01,0x0a,0x01,0x81}, floor=0x369, location="Bodley", },
    {x=0x1b0, y=0x2e0, area = {0x01,0x0a,0x01,0x81}, floor=0x309, location="Bodley", },
    {x=0x170, y=0x2e0, area = {0x01,0x0a,0x01,0x81}, floor=0x309, location="Bodley", },
    {x=0x130, y=0x2e0, area = {0x01,0x0a,0x01,0x81}, floor=0x309, location="Bodley", },
    {x=0x1d0, y=0x180, area = {0x01,0x0a,0x00,0x81}, floor=0x1a9, location="Bodley", },
    {x=0x150, y=0x170, area = {0x01,0x0a,0x00,0x81}, floor=0x1a9, location="Bodley", },
    {x=0x170, y=0x100, area = {0x01,0x0a,0x00,0x81}, floor=0x129, location="Bodley", },
    {x=0x10, y=0x90, area = {0x01,0x0a,0x00,0x81}, floor=0xc9, location="Bodley", },
    {x=0x20, y=0x90, area = {0x01,0x0a,0x00,0x81}, floor=0xc9, location="Bodley", },
    {x=0x10, y=0xa0, area = {0x01,0x0a,0x00,0x81}, floor=0xc9, location="Bodley", },
    {x=0x20, y=0xa0, area = {0x01,0x0a,0x00,0x81}, floor=0xc9, location="Bodley", },
    {x=0x3c0, y=0x90, area = {0x01,0x0a,0x00,0x81}, floor=0xc9, location="Bodley", },
    {x=0x60, y=0x40, area = {0x01,0x0a,0x01,0x81}, floor=0x69, location="Bodley", },
    {x=0xb0, y=0x40, area = {0x01,0x0a,0x01,0x81}, floor=0x69, location="Bodley", },
    {x=0x50, y=0x80, area = {0x04,0x02,0x00,0x41}, floor=0xb9, location="Wicked Ditch", },
    {x=0xc0, y=0x80, area = {0x04,0x02,0x00,0x41}, floor=0xb9, location="Wicked Ditch", },
    {x=0x200, y=0x70, area = {0x04,0x02,0x00,0x41}, floor=0xc3, location="Wicked Ditch", },
    {x=0x310, y=0x80, area = {0x04,0x02,0x00,0x41}, floor=0xb9, location="Wicked Ditch", },
    {x=0x3e0, y=0x80, area = {0x04,0x02,0x00,0x41}, floor=0xc9, location="Wicked Ditch", },
    {x=0x50, y=0x90, area = {0x00,0x14,0x00,0x01}, floor=0xc9, location="(room)", },
    {x=0x80, y=0x90, area = {0x00,0x14,0x00,0x01}, floor=0xc9, location="(room)", },
    {x=0x260, y=0x80, area = {0x00,0x05,0x00,0x00}, floor=0xc9, location="Doina", },
    {x=0x270, y=0x80, area = {0x00,0x05,0x00,0x00}, floor=0xc9, location="Doina", },
    {x=0xe0, y=0xa0, area = {0x00,0x15,0x00,0x01}, floor=0xc9, location="(room)", },
    {x=0xd0, y=0xa0, area = {0x00,0x15,0x00,0x01}, floor=0xc9, location="(room)", },
    {x=0xd0, y=0x190, area = {0x00,0x15,0x00,0x01}, floor=0x1a9, location="(room)", },
    {x=0x150, y=0x70, area = {0x02,0x08,0x00,0x41}, floor=0xb1, location="North Bridge", },
    {x=0x1b0, y=0x70, area = {0x02,0x08,0x00,0x41}, floor=0xb1, location="North Bridge", },
    {x=0x250, y=0x70, area = {0x02,0x08,0x00,0x41}, floor=0xb1, location="North Bridge", },
    {x=0x2b0, y=0x70, area = {0x02,0x08,0x00,0x41}, floor=0xb1, location="North Bridge", },
    {x=0x90, y=0x80, area = {0x02,0x08,0x02,0x41}, floor=0xb9, location="Dora Woods", },
    {x=0x150, y=0x80, area = {0x02,0x08,0x02,0x41}, floor=0xa9, location="Dora Woods", },
    {x=0x190, y=0x80, area = {0x02,0x08,0x02,0x41}, floor=0xa9, location="Dora Woods", },
    {x=0x90, y=0x80, area = {0x02,0x09,0x00,0x41}, floor=0xb9, location="Dora Woods", },
    {x=0xf0, y=0x60, area = {0x02,0x09,0x01,0x41}, floor=0x99, location="East Bridge", },
    {x=0x150, y=0x60, area = {0x02,0x09,0x01,0x41}, floor=0x99, location="East Bridge", },
    {x=0x1b0, y=0x60, area = {0x02,0x09,0x01,0x41}, floor=0x99, location="East Bridge", },
    {x=0x250, y=0x60, area = {0x02,0x09,0x01,0x41}, floor=0x99, location="East Bridge", },
    {x=0x100, y=0xa0, area = {0x02,0x09,0x02,0x41}, floor=0xd9, location="Bordia Mountains", },
    {x=0x140, y=0xa0, area = {0x02,0x09,0x02,0x41}, floor=0xd9, location="Bordia Mountains", },
    {x=0x170, y=0xa0, area = {0x02,0x09,0x02,0x41}, floor=0xd9, location="Bordia Mountains", },
    {x=0x1a0, y=0xa0, area = {0x02,0x09,0x02,0x41}, floor=0xd9, location="Bordia Mountains", },
    {x=0x1e0, y=0xa0, area = {0x02,0x09,0x02,0x41}, floor=0xd9, location="Bordia Mountains", },
    {x=0x220, y=0xa0, area = {0x02,0x09,0x02,0x41}, floor=0xd9, location="Bordia Mountains", },
    {x=0x250, y=0xa0, area = {0x02,0x09,0x02,0x41}, floor=0xd9, location="Bordia Mountains", },
    {x=0x2c0, y=0xa0, area = {0x02,0x09,0x02,0x41}, floor=0xd9, location="Bordia Mountains", },
    {x=0x300, y=0xa0, area = {0x02,0x09,0x02,0x41}, floor=0xd9, location="Bordia Mountains", },
    {x=0x330, y=0xa0, area = {0x02,0x09,0x02,0x41}, floor=0xd9, location="Bordia Mountains", },
    {x=0x360, y=0xa0, area = {0x02,0x09,0x02,0x41}, floor=0xd9, location="Bordia Mountains", },
    {x=0x3d0, y=0xc0, area = {0x02,0x09,0x02,0x41}, floor=0xc9, location="Bordia Mountains", },
    {x=0x3d0, y=0xb0, area = {0x02,0x09,0x02,0x41}, floor=0xc9, location="Bordia Mountains", },
    {x=0x3d0, y=0xa0, area = {0x02,0x09,0x02,0x41}, floor=0xc9, location="Bordia Mountains", },
    {x=0x3d0, y=0x90, area = {0x02,0x09,0x02,0x41}, floor=0xc9, location="Bordia Mountains", },
    {x=0x3d0, y=0x80, area = {0x02,0x09,0x02,0x41}, floor=0xc9, location="Bordia Mountains", },
    {x=0x3c0, y=0x80, area = {0x02,0x09,0x02,0x41}, floor=0xc9, location="Bordia Mountains", },
    {x=0x3c0, y=0x90, area = {0x02,0x09,0x02,0x41}, floor=0xc9, location="Bordia Mountains", },
    {x=0x3c0, y=0xb0, area = {0x02,0x09,0x02,0x41}, floor=0xc9, location="Bordia Mountains", },
    {x=0x3c0, y=0xa0, area = {0x02,0x09,0x02,0x41}, floor=0xc9, location="Bordia Mountains", },
    {x=0x3c0, y=0xc0, area = {0x02,0x09,0x02,0x41}, floor=0xc9, location="Bordia Mountains", },
    {x=0x3b0, y=0x80, area = {0x02,0x09,0x02,0x41}, floor=0xc9, location="Bordia Mountains", },
    {x=0x3b0, y=0x90, area = {0x02,0x09,0x02,0x41}, floor=0xc9, location="Bordia Mountains", },
    {x=0x3b0, y=0xa0, area = {0x02,0x09,0x02,0x41}, floor=0xc9, location="Bordia Mountains", },
    {x=0x3b0, y=0xb0, area = {0x02,0x09,0x02,0x41}, floor=0xc9, location="Bordia Mountains", },
    {x=0x3b0, y=0xc0, area = {0x02,0x09,0x02,0x41}, floor=0xc9, location="Bordia Mountains", },
    {x=0x3a0, y=0xc0, area = {0x02,0x09,0x02,0x41}, floor=0xc9, location="Bordia Mountains", },
    {x=0x3a0, y=0xb0, area = {0x02,0x09,0x02,0x41}, floor=0xc9, location="Bordia Mountains", },
    {x=0x3a0, y=0xa0, area = {0x02,0x09,0x02,0x41}, floor=0xc9, location="Bordia Mountains", },
    {x=0x3a0, y=0x90, area = {0x02,0x09,0x02,0x41}, floor=0xc9, location="Bordia Mountains", },
    {x=0x3a0, y=0x80, area = {0x02,0x09,0x02,0x41}, floor=0xc9, location="Bordia Mountains", },
    {x=0x80, y=0x100, area = {0x02,0x08,0x02,0x41}, floor=0x149, location="Dora Woods", },
    {x=0x70, y=0x100, area = {0x02,0x08,0x02,0x41}, floor=0x149, location="Dora Woods", },
    {x=0xc0, y=0xa0, area = {0x00,0x16,0x00,0x01}, floor=0xc9, location="(room)", },
    {x=0xc0, y=0x90, area = {0x00,0x17,0x00,0x01}, floor=0xc9, location="(room)", },
    {x=0x40, y=0x70, area = {0x04,0x03,0x00,0x41}, floor=0xa9, location="Vrad Graveyard", },
    {x=0xa0, y=0x70, area = {0x04,0x03,0x00,0x41}, floor=0xa9, location="Vrad Graveyard", },
    {x=0x120, y=0x70, area = {0x04,0x03,0x00,0x41}, floor=0xa9, location="Vrad Graveyard", },
    {x=0x160, y=0x70, area = {0x04,0x03,0x00,0x41}, floor=0xa9, location="Vrad Graveyard", },

    {x=0x70, y=0xb0, area = {0x04,0x00,0x00,0x41}, floor=0xc9, location="Vrad Mountain", item="Gold", },
    {x=0x20, y=0xc0, area = {0x03,0x03,0x02,0x41}, floor=0xe9, location="Debious Woods", item="Axe", },
    {x=0x330, y=0xb0, area = {0x04,0x03,0x00,0x41}, floor=0xd9, location="Vrad Graveyard", item="Banshee Boomerang", },
    {x=0x260, y=0x120, area = {0x01,0x0a,0x01,0x81}, floor=0x1a9, location="Bodley", item="Simon's Plate", },
    {x=0x120, y=0x270, area = {0x01,0x0a,0x01,0x81}, floor=0x309, location="Bodley", item="Gold", },
    {x=0x30, y=0x110, area = {0x02,0x03,0x03,0x41}, floor=0x149, location="Aljiba Woods", item="Night Armor", },
}

return candles
