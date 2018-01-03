# VIM PuppetNewFile plugin

## Context

This plugin was mainly created for my personal use.

I was getting bored of always creating manually:
* my directories structure (`mkdir -p manifests/profile/myserver/mysomething`)
* my puppet files header (`class mymodule::profile::myserver::mysomething::myclass`)

## Install

If you don't have a preferred installation method, one option is to install [pathogen.vim](https://github.com/tpope/vim-pathogen), and then copy and paste:

```
cd ~/.vim/bundle
git clone https://github.com/riton/vim-puppetnewfile.git
```

## Usage

### Warning

This plugin expects that you're working from your module basedir (the one containing the `manifests`, `lib`, `functions` directories).

The directory name is used to extract the _module name_.

For instance, if your current working directory is `/home/myuser/dev/puppet/mymodule`, the _module name_ that will be extracted will be `mymodule`.

This plugin also supports (for my personal use) the fact that module directories can end with a `.git`. So `/home/myuser/dev/puppet/mymodule.git` will also extract the _module name_ `mymodule` as expected.


```
$ mkdir /tmp/test-vim-puppetnewfile && cd /tmp/test-vim-puppetnewfile
```

Create a dummy directory as if it was our puppet module basedir and `chdir()` to this directory
```
$ mkdir mymodule && cd mymodule
```

Let's simulate puppet module development and create a resource file

```
$ vim manifests/config/main.pp
```

The plugin will pre-fill the file with the following content

```puppet
#
class mymodule::config::main(
) inherits ::mymodule
{

}

# vim: ft=puppet
```

and create the directories `manifests` and `manifests/config` for you.

## Configuration

**Disable auto-mkdir**
```
let g:puppetnewfile_auto_create_dirs=0
```

**Where to find templates files**
```
let g:puppetnewfile_templates="/home/user/.vim/templates"
```

You must have a `class.pp` and `function.pp` file in this directory.

Those will be used to create new files.

Each instance of `__RESOURCENAME__` and `__MODULENAME__` will be replaced accordingly.
