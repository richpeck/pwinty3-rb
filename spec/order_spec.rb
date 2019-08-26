RSpec.describe Pwinty3::Order do
	it "has an Order class" do
		expect(Pwinty3::Order).to be_truthy
	end

  	it "can create an order" do
  		VCR.use_cassette('order/create') do
		  	order = Pwinty3::Order.create(
		  		recipientName: "FirstName LastName",
				countryCode: "US",
				preferredShippingMethod: "Budget"
		  	)
		  	expect(order).to be_kind_of(Pwinty3::Order)
		  	expect(order.id).to be_truthy

		  	expect(order.recipientName).to eq('FirstName LastName')
		  	expect(order.countryCode).to eq('US')
		  	expect(order.preferredShippingMethod).to eq('Budget')
		 end
	 end

	it "can get an order" do
	  	VCR.use_cassette('order/get') do
			order = Pwinty3::Order.find(794822)

	  	 	expect(order).to be_kind_of(Pwinty3::Order)
	  	 	expect(order.id).to eq(794822)
	  	 	expect(order.recipientName).to eq('FirstName LastName')
		  	expect(order.countryCode).to eq('US')
		  	expect(order.preferredShippingMethod).to eq('Budget')
	  	end
	end

	it "can update an order" do
		VCR.use_cassette('order/update') do
			order = Pwinty3::Order.create(
		  		recipientName: "FirstName LastName",
				countryCode: "US",
				preferredShippingMethod: "Budget"
		  	)

			order.update(
				address1: 'House number',
				address2: 'Street address'
			)

			expect(order.address1).to eq('House number')
			expect(order.address2).to eq('Street address')
			expect(order.recipientName).to eq('FirstName LastName')
			expect(order.countryCode).to eq('US')
			expect(order.preferredShippingMethod).to eq('Budget')
		end
	end

	it "can list orders" do
		VCR.use_cassette('order/list') do
			orders = Pwinty3::Order.list

			expect(orders[0]).to be_kind_of(Pwinty3::Order)
			# This should be equal to Order.count but there is a problem with the API's pagination
			expect(orders.count).to eq(100)
		end
	end

	it "can count orders" do
		VCR.use_cassette('order/count') do
			count = Pwinty3::Order.count
			expect(count).to be > 467
		end
	end

  	it "can validate an order" do
  		VCR.use_cassette('order/get') do
	  		@order = Pwinty3::Order.find(794822)
	  	end

	  	VCR.use_cassette('order/status') do
	  		status = @order.submission_status

	  		expect(status).to be_kind_of(Pwinty3::OrderStatus)
	  		expect(status.id).to eq(@order.id)
	  		expect(status.id).to eq(794822)
	  		expect(status.isValid).to be(false)
	  		expect(status.generalErrors).to contain_exactly('NoItemsInOrder', 'PostalAddressNotSet', 'PostalAddressNotSet')
	  	end
  	end

  	it "can add an image to an order" do
  		VCR.use_cassette('order/create') do
	  		@order = Pwinty3::Order.create(
		  		recipientName: "FirstName LastName",
				countryCode: "US",
				preferredShippingMethod: "Budget"
		  	)
	  	end

	  	VCR.use_cassette('order/add_image') do
	  		@order.add_image(
	  			sku: "GLOBAL-PHO-4X6-PRO",
	  			url: "http://example.com/mytestphoto.jpg",
	  			copies: 1,
	  		)
	  	end

	  	expect(@order.images.count).to eq 1
	  	expect(@order.images[0].status).to eq "NotYetDownloaded"
	  	expect(@order.images[0].copies).to eq 1
  	end

  	it "can add an image to an order" do
  		VCR.use_cassette('order/add_multi_images') do
	  		order = Pwinty3::Order.create(
		  		recipientName: "FirstName LastName",
				countryCode: "US",
				preferredShippingMethod: "Budget"
		  	)
		  	expect(order.images.count).to eq 0
	  	
	  		order.add_images(
	  			[{
		  			sku: "GLOBAL-PHO-4X6-PRO",
		  			url: "http://example.com/myTestPhoto.jpg",
		  			copies: 1,
		  		}, {
		  			sku: "GLOBAL-PHO-10X12-PRO",
		  			url: "http://example.com/myLargeTestPhoto.jpg",
		  			copies: 1,
		  		}]
	  		)

		  	expect(order.images.count).to eq 2

		  	order.images.each do |order_image|
		  		expect(order_image.status).to eq "NotYetDownloaded"
			  	expect(order_image.copies).to eq 1
		  	end
		 end
  	end

end
