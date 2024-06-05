# arthas-cheetsheet
This is a cheat sheet for the Arthas tool 

## Introduction

[Arthas](https://github.com/alibaba/arthas) is a complete set of diagnostic tools to troubleshoot production issues on the fly. `

```
curl -O https://arthas.aliyun.com/arthas-boot.jar
java -jar arthas-boot.jar
```
 
After you select the process you want Arthas to be attached to, you can use various commands

TODO -> PUT EXAMPLE OPEN CONSOLE, DO SIMPLE OPERATION AND EXIT


## Typical USE CASES

### Intercept calls to a method and show params and return value

Let's assume this function in class (com.test.MyClass) which is called very often

```java

    public  int myMethod(String customer, List<String> list) throws IOException {
         int returnValue = list.size();
         String joinString = String.join(" - ", list);
         int sizeJoinString = joinString.length() + customer;
         return sizeJoinString;
    }
```



The following command will show for each invocation (grouped in seconds) all the params, returned object and exception (if exist) 

```
watch com.test.MyClass myMethod '{params[0],params[1],returnObj,throwExp}' -x 2
```

then the outcome would be like:

```

method=com.test.MyClass.myMethod location=AtExit
ts=2024-06-05 13:43:17; [cost=0.024663ms] result=@ArrayList[
    @String[1100075],             <---------- THIS MEANS that first parameter is a String with value 1100075
    @ArrayList[                   <---------- THIS MEANS that second parameter is a list with two parameters   
        @String[hola],
        @String[caracola],
    ],
    @Integer[15],                <---------- THIS MEANS return value is 15
    null,                        <---------- THIS MEANS THERE IS NO EXCEPTION
]



```

Now let's assume the second parameter of the method (the list) is null
let's execute the same arthas command
 
the result would be
```
method=com.test.MyClass.myMethod location=AtExceptionExit
ts=2024-06-05 13:45:42; [cost=0.037923ms] result=@ArrayList[
    @String[1200002],
    null,
    null,
    java.lang.NullPointerException
	at com.test.MyClass.myMethod(Test.java:264)
	at com.test.MyClass.lambda$getCallableForThread$0(Test.java:213)
	at java.util.concurrent.FutureTask.run(FutureTask.java:266)
	at java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1149)
	at java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:624)
	at java.lang.Thread.run(Thread.java:750)
,
]
```
 

### ver variable de una clase (singleton) o instancia (buscar la instancia de la clase)
TODO



### ver tiempos de ejecución de un metodo
TODO


### invocar un metodo (instancia o clase)
TODO


### cambiar clase en caliente

TODO


