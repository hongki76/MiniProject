package com.model2.mvc.service.domain;

import java.sql.Date;


public class Product {

	private int prodNo; // 상품번호
	private String fileName; // 이미지 파일명
	private String manuDate; // 제조일자
	private int price; // 가격
	private String prodDetail; // 상품상세정보
	private String prodName; // 상품명
	private Date regDate; // 등록일자
	private String proTranCode; // 상품코드(0:판매중, 1:구매완료, 2:배송중, 3:배송완료)
	private String proTranState;	// 상품 거래 상태
	
	public Product(){
	}
	
	public String getFileName() {
		return fileName;
	}
	
	public void setFileName(String fileName) {
		this.fileName = fileName;
	}
	
	public String getManuDate() {
		return manuDate;
	}
	
	public void setManuDate(String manuDate) {
		this.manuDate = manuDate;
	}
	
	public int getPrice() {
		return price;
	}
	
	public void setPrice(int price) {
		this.price = price;
	}
	
	public String getProdDetail() {
		return prodDetail;
	}
	
	public void setProdDetail(String prodDetail) {
		this.prodDetail = prodDetail;
	}
	
	public String getProdName() {
		return prodName;
	}
	
	public void setProdName(String prodName) {
		this.prodName = prodName;
	}
	
	public int getProdNo() {
		return prodNo;
	}
	
	public void setProdNo(int prodNo) {
		this.prodNo = prodNo;
	}
	
	public Date getRegDate() {
		return regDate;
	}
	
	public void setRegDate(Date regDate) {
		this.regDate = regDate;
	}
	
	public String getProTranCode() {
		return proTranCode;
	}
	
	public void setProTranCode(String proTranCode) {
		this.proTranCode = proTranCode;
	}
	
	public String getProTranState() {
	    return proTranState;
	}
	
	public void setProTranState(String tranState) {
	    this.proTranState = tranState;
	}

	// Override
	public String toString() {
		return "Product : [fileName]" + fileName
				+ "[manuDate]" + manuDate+ "[price]" + price + "[prodDetail]" + prodDetail
				+ "[prodName]" + prodName + "[prodNo]" + prodNo;
	}	
}