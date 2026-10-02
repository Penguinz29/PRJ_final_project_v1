package com.mathtutor.filter;

import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.annotation.WebFilter;
import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.util.logging.Level;
import java.util.logging.Logger;

@WebFilter("/*")
public class EncodingFilter implements Filter {
    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain) throws UnsupportedEncodingException, IOException{
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        
        String path = ((jakarta.servlet.http.HttpServletRequest) request).getRequestURI();
        if (!path.matches(".*\\.(css|js|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$")) {
            response.setContentType("text/html; charset=UTF-8");
        }
        
        try {
            chain.doFilter(request, response);
        } catch (ServletException ex) {
            Logger.getLogger(EncodingFilter.class.getName()).log(Level.SEVERE, null, ex);
        }
    }
}
