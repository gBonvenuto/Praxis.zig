# praxis.zig
PT: Tentando fazer um RTOS em Zig (e possivelmnte documentando minha jornada)

EN: Trying to build an RTOS in Zig (and possibly documenting my journey)

# TODO

I'll start with the arduino-uno

- [x] Create a linker-script
- [x] Create a beginner friendly build process
- [x] Learn how to turn it into a library
- [ ] Create basic drivers (uart, GPIO, LED, button)
  - [x] UART
  - [x] LED
  - [ ] GPIO
  - [ ] BUTTON
  - [ ] BUZZER
  - [ ] DISPLAY
- [ ] Create a device-tree like structure
  - Currently rethink the current structure
  - Currently the device-tree like structure does not play well with LSP because of complicated build process. I have to rethink a more robust approach
- [ ] Create interrupts
- [ ] Create a scheduler
- [ ] Create tests
- [ ] Create examples
  - [x] LED
- [ ] Port to STM32 blackpill

By the end of each task I'll write the devlog

_Note: I've stalled this project since joining the GeoBench project. But I still intend to continue the development and the devlog._ 
