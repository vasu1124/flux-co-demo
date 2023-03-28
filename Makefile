include .env

.PHONY: deploy-system
deploy-system:
	-kubectl apply -k mpas/mpas-system
	kubectl apply -f mpas/mpas-system/secrets.yaml

.PHONY: subscribe-myproduct
subscribe-myproduct:
	kubectl apply -k mpas/btp-co-demo/myproduct

.PHONY: publish-myproduct
publish-myproduct: ctf-push
	ocm get resources -o yaml --recursive ${OCI}/${ORG}/ocm//${COMPONENT_NAME_PREFIX}/${NAME} -o treewide

.PHONY: ocm
ocm:
	mkdir -p ./ocm/.gen
	ocm cv add -cf -F ./ocm/.gen/ctf ./ocm/component.yaml  \
		--settings ./ocm/settings.yaml
	ocm get resources -o yaml --recursive ./ocm/.gen/ctf -o treewide

.PHONY: ctf-push
ctf-push: ocm
	ocm transfer ctf ./ocm/.gen/ctf ${OCI}/${ORG}/ocm

.PHONY: clean
	rm -rf ocm/.gen
