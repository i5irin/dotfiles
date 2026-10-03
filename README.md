# dotfiles

A set of settings and frequently used application setups that I use.  
This dotfiles is recommended for people who work on multiple platforms.

## Features

+ Settings for macOS, Ubuntu, and Windows that are similar in usability.
+ Idempotent-conscious setup scripts that can be re-run repeatedly.
+ List of [customizable applications to be installed](#changing-the-applications-to-be-installed).
+ A virtual environment using Vagrant and Docker for previewing.

## Usage

1. Download this repository by cloning or otherwise.  
(It is recommended that you create a directory named dotfiles directly under home directory.)

macOS/Ubuntu

```Shell
git clone git@github.com:i5irin/dotfiles.git "${HOME}/dotfiles"
```

Windows

```PowerShell
git clone git@github.com:i5irin/dotfiles.git "${HOME}\dotfiles"
```

2. Run the setup script for each OS.

The environment will be set up and the application will be installed.  
If you want to customize the applications to be installed, read [Changing the applications to be installed](#changing-the-applications-to-be-installed).

macOS
```Shell
chmod u+x mac/setup_macos.sh && ./mac/setup_macos.sh
```

Ubuntu
```Shell
chmod u+x ubuntu/setup_ubuntu.sh && ./ubuntu/setup_ubuntu.sh
```

Windows
```PowerShell
# ローカルコンピュータの.ps1ファイルか、ファイル共有またはダウンロードした署名付きの.ps1ファイルが実行できるようにする
Set-ExecutionPolicy RemoteSigned
Set-MpPreference -DisableRealtimeMonitoring 0
.\Windows\SetupWindows.ps1
```

## Changing the applications to be installed

Create a file with a prefix of "My" in the application list file to be installed.  
By putting the name or Id and such in this file, you can add applications to be installed, and by putting the name or Id and such that exists in the list file without "My" prefix in this file, you can exclude them from being installed.

**Files starting with "My" are not managed by Git, so you can `git pull` them even if you change the list of applications.**

### Changing Applications in macOS

It uses Homebrew (and cask, mas) to manage the applications it installs.  
Copy "MyBrewfile.sample" with the name "MyBrewfile" and put the list in the file.

### Changing Applications in Windows

It uses winget (Windows Package Manager) and Scoop to install applications.  
For winget, copy "MyWinget.json.sample" with the name "MyWinget.json" and put the list in the file.  
For Scoop, copy "MyScoop.txt.sample" with the name "MyScoop.txt" and put the list in the file.

### Changing Applications in Ubuntu

It uses apt and Snappy to install applications.  
For apt, copy "my_apt_installs.txt.sample" with the name "my_apt_installs.txt" and put the list in the file.  
For apt, copy "my_apt_installs.txt.sample" with the name "my_apt_installs.txt" and put the list in the file.  

## TODO

+ caskのマニュアルインストールの実行に対応する

## Karabiner-Elements config

It links from the folder which has Karabiner-Elements config files not to override this repo's config.

https://pqrs.org/osx/karabiner/document.html#configuration-file-path

### Using with Windows (etc. Remote desktop)

Enable complex_modifications in the order of following to avoid left-cmd key recognized as Windows-key.

1. "Sends tilde-key and left-option key when command-key pressed on Windows-RDP."
2. "Sends Eisuu / Kana key when the command key is pressed alone."
WslRegisterDistribution failed with error: 0x80370102

### macOSの設定

"System Preferences" > "Security & Privacy" > "Privacy" > "Full Disk Access"でターミナルアプリケーションに重要なデータや管理設定などへのアクセス権限を与えると特定のplistの閲覧やディスクの使用状況など開発に使う情報が確認できます。
(comから始まるdefaultsコマンドで扱う設定のこと)

### WSL2をVMWareなどの仮想マシンで利用する

VMWareなど仮想マシン上のWindowsでWSL2のインストールが含まれるスクリプトを実行する際は先に仮想マシンのハイパーバイザーアプリケーションの実行(Intel VT-x/EPTの有効化)を許可してください。

git_commit_at '2022-06-18 23:55:44 +0900' "Rename folders to change case"
git_commit_at '2022-09-18 23:17:59 +0900' "docs: update changelog for v0.4.0"

仮想デスクトップの設定をできるようにする
https://stackoverflow.com/questions/6768684/osx-lion-applescript-how-to-get-current-space-from-mission-control

テストしてみる

## コントリビュート
Fix that dotfiles paths are not passed between setup scripts
宣言と手続きが混ざるのがセットアップだと思っている。
宣言を手続きから何度も呼び出す都合上宣言となる各ドットファイルは冪等性を持ってほしい
Move the preferences section from the setup script for Windows to a separate file

コミット予定

snapのインストール一覧ファイルがcommit対象になっているけど大丈夫か？
=> snap.txt.sampleを作る

macOSのlaunchdが止まっているように見える、動くようにする。

ブログに使えそうなドキュメントを分けて管理する

インストール前後の情報表示関数をmacOSとubuntu共通で使えるところに移動する

macOSでの実行を確認する（冪等性チェックもする）

snap --classicでインストールする一覧を用意する

インストール・設定のスクリプトをsetupフォルダー（インストールから設定まで）とconfigure（設定のみ）に分ける

機能説明のドキュメントを追加する

使い方概要のドキュメントを追加する

インストールするアプリケーションのカスタム方法のドキュメントを追加する

chmod u+x ./macos/update_applications.sh
mkdir -p ~/Library/LaunchAgents && cp ./macos/com.i5irin.dotfiles.updateapps.plist ~/Library/LaunchAgents/com.i5irin.dotfiles.updateapps.plist
launchctl load ~/Library/LaunchAgents/com.i5irin.dotfiles.updateapps.plist

Ubuntuのインストールスクリプトを通す
macOSのインストールスクリプトを通す
Windowsのインストールスクリプトを通す
curlとapt-getのサイレントオプション付きのインストールスクリプト用のエイリアスを定義する
何をしているのか進捗表示をつける

/dev/nullに捨てられない

shellscriptの中でcurlしたあとにそのファイルを使うときダウンロードしたファイルを相対パスで./ファイルのように指定しないとエラーが出てしまう

チートシートコマンド naviを入れる
