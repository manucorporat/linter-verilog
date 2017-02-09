# linter-verilog

Atom linter for Verilog and SystemVerilog using [Verilaror](http://www.veripool.org/wiki/verilator).

There is also an option use [Icarus Verilog](http://iverilog.icarus.com) which only supports old Verilog.

![Screenshot](https://raw.githubusercontent.com/manucorporat/linter-verilog/master/screenshot.png)


# Installation

1. Install one of the supported simulators

`Verilator` and `iverilog`/`icarus-verilog` are both opensource softwares and you should find a corresponding package for your Linux Distribution.

On Debian derivatives, it should be as easy as:

```
$ apt-get install verilator
$ apt-get install iverilog
```

On MacOs, they should be available using **`brew`**.

If you are writing SystemVerilog, you will have to install **Verilator** as iverilog does not support recent Verilog Syntax.


2. Install the atom package: 

From the `Install` pane of the `Settings` menu or through the command line:

```
$ apm install linter-verilog
```
