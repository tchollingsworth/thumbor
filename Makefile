run: compile_ext
	@PYTHONPATH=.:$$PYTHONPATH python thumbor/server.py -l debug

compile_ext:
	python setup.py build_ext -i

test pyvows: compile_ext redis mongo
	@PYTHONPATH=.:$$PYTHONPATH pyvows -v --profile --cover --cover_package=thumbor --cover_threshold=90 vows/

mysql_test: pretest
	@PYTHONPATH=.:$$PYTHONPATH nosetests -v -s --with-coverage --cover-erase --cover-package=thumbor tests/test_mysql_storage.py

mongo:
	@rm -rf /tmp/thumbor/mongodata && mkdir -p /tmp/thumbor/mongodata
	@mongod --dbpath /tmp/thumbor/mongodata --logpath /tmp/thumbor/mongolog --quiet &

redis:
	@ps aux | egrep redis | egrep -v egrep | awk '{ print $$2 }' | xargs kill -9
	@redis-server redis.conf &
