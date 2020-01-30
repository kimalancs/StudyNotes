# markdown notes

## 标题

标题的格式：**#+空格+一级标题**  

```markdown
# 一级标题

## 二级标题

##### 五级标题
```

标题后可以有两个空格或没有空格，不能只有一个空格  

标题上下都应该是空行

换行在末尾添加两个空格再回车

使用空行来分开段落（两次回车）

空行只能有一行，不能有多个空行

## 代码

* 行内代码，用单个反引号前后包裹，`print("hello")`

* 代码块，用三个反引号前后包裹，也可以在三个反引号之后指定语言（Github flavored markdown）  
代码块上下也要是空行  
代码块也可以用四个空格或一个制表符（Tab），不能实现语法高亮等功能，较陈旧，有些编辑器不支持，如Typora

```go
package main

import "fmt"

func main() {
    fmt.Println("Hello World")
}
```