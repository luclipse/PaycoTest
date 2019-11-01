package com.luclipse.paycoTest.payco.web;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
public class JspViewTestController {

    @RequestMapping(value="/")     // localhost
    public String root() {
        return "viewtest";         // 실제 호출될 /WEB-INF/jsp/viewtest.jsp
    }

    @RequestMapping(value="/test") // localhost/test
    public String test() {
        return "test/test2";       // 실제 호출될 /WEB-INF/jsp/test/viewtest2.jsp
    }

}