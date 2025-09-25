package com.model2.mvc.service.domain;

import java.sql.Date;

public class Purchase implements java.io.Serializable {

    private static final long serialVersionUID = 1L;

    private int tranNo;                 // 구매번호
    private Product purchaseProd;     // 구매 물품 정보
    private User buyer;               // 구매자 정보
    private String paymentOption;       // 결제 방법(1:현금/2:카드)
    private String receiverName; // 구매자 이름
    private String receiverPhone; // 구매자 연락처 
    private String receiverEmail; // 구매자 Email
    private String dlvyRequest;         // 배송 요청사항
    private String dlvyDate;            // 배송 희망 일자(yyyyMMdd)
    private String tranCode;            // 구매 상태 코드 ('0'=판매중, '1'=배송중, '2'=배송완료)
    private Date orderDate;             // 주문일자

    public Purchase() {}

    public int getTranNo() { return tranNo; }
    public void setTranNo(int tranNo) { this.tranNo = tranNo; }

    public Product getPurchaseProd() { return purchaseProd; }
    public void setPurchaseProd(Product purchaseProd) { this.purchaseProd = purchaseProd; }

    public User getBuyer() { return buyer; }
    public void setBuyer(User buyer) { this.buyer = buyer; }

    public String getPaymentOption() { return paymentOption; }
    public void setPaymentOption(String paymentOption) { this.paymentOption = paymentOption; }

    public String getDlvyRequest() { return dlvyRequest; }
    public void setDlvyRequest(String dlvyRequest) { this.dlvyRequest = dlvyRequest; }

    public String getDlvyDate() { return dlvyDate; }
    public void setDlvyDate(String dlvyDate) { this.dlvyDate = dlvyDate; }

    public String getTranCode() { return tranCode; }
    public void setTranCode(String tranCode) { this.tranCode = tranCode; }

    public Date getOrderDate() { return orderDate; }
    public void setOrderDate(Date orderDate) { this.orderDate = orderDate; }

    @Override
    public String toString() {
        return "Purchase{" +
                "tranNo=" + tranNo +
                ", purchaseProd=" + (purchaseProd != null ? purchaseProd.getProdNo() : null) +
                ", buyer=" + (buyer != null ? buyer.getUserId() : null) +
                ", paymentOption='" + paymentOption + '\'' +
                ", dlvyRequest='" + dlvyRequest + '\'' +
                ", dlvyDate='" + dlvyDate + '\'' +
                ", tranCode='" + tranCode + '\'' +
                ", orderDate=" + orderDate +
                '}';
    }

	public String getReceiverName() {
		return receiverName;
	}

	public void setReceiverName(String receiverName) {
		this.receiverName = receiverName;
	}

	public String getReceiverPhone() {
		return receiverPhone;
	}

	public void setReceiverPhone(String receiverPhone) {
		this.receiverPhone = receiverPhone;
	}

	public String getReceiverEmail() {
		return receiverEmail;
	}

	public void setReceiverEmail(String receiverEmail) {
		this.receiverEmail = receiverEmail;
	}
	
	public String getPaymentOptionName() {
	    if (paymentOption == null) return "";
	    // 앞뒤 공백 제거
	    String opt = paymentOption.trim();

	    switch (opt) {
	        case "1": return "현금구매";
	        case "2": return "카드구매";
	        default : return opt;   // 알 수 없는 코드는 그대로 노출
	    }
	}
}
