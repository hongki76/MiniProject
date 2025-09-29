package com.model2.mvc.service.domain;

public class ProductFile {
	private int fileNo; // 파일번호
	private int prodNo; // 상품번호
	private String fileName; // 파일명
	
	public int getFileNo() {
		return fileNo;
	}
	
	public void setFileNo(int fileNo) {
		this.fileNo = fileNo;
	}

	public int getProdNo() {
		return prodNo;
	}

	public void setProdNo(int prodNo) {
		this.prodNo = prodNo;
	}

	public String getFileName() {
		return fileName;
	}

	public void setFileName(String fileName) {
		this.fileName = fileName;
	}

	@Override
	public String toString() {
		return "ProductFile : [fileNo]" + fileNo
				+ "[prodNo]" + prodNo + "[fileName]" + fileName;
	}
}
