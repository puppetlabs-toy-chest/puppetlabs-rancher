RANCHER_IMAGES = [
]

RANCHER_CONTAINERS = [
]


shared_examples 'a system running rancher' do
	RANCHER_IMAGES.each do |image|
	  describe docker_image(image) do
      it { should exist }
    end
  end

  RANCHER_CONTAINERS.each do |container|
    describe docker_container(container) do
      it { should be_running }
    end
  end
end
